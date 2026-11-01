<script lang="ts">
	import { onMount } from 'svelte';
	import { quoteStore } from '#lib/stores/quoteStore';
	import { toastStore } from '#lib/stores/toastStore';
	import Table from '#lib/components/Table.svelte';
	import Button from '#lib/components/Button.svelte';
	import Input from '#lib/components/Form/Input.svelte';
	import TextArea from '#lib/components/Form/TextArea.svelte';
	import Select from '#lib/components/Form/Select.svelte';
	import Modal from '#lib/components/Modal.svelte';
	import Toast from '#lib/components/Toast.svelte';
	import PageContainer from '#lib/components/Layout/PageContainer.svelte';
	import { Download, Plus, Search } from '@lucide/svelte';
	import type { Quote, QuoteStatus } from '#lib/types/models';

	let isLoading = $state(true);
	let isSaving = $state(false);
	let showModal = $state(false);
	let editingId = $state<string | null>(null);
	let searchQuery = $state('');
	let statusFilter = $state<QuoteStatus | 'all'>('all');
	let selectedItems = $state(new Set<Quote>());

	let formData = $state({
		quoteNumber: '',
		customerName: '',
		amount: 0,
		tax: 0,
		total: 0,
		description: '',
		notes: '',
		status: 'draft' as QuoteStatus,
		validUntil: new Date().toISOString().split('T')[0]
	});

	const statusOptions = [
		{ value: 'all' as const, label: 'Tüm Teklifler' },
		{ value: 'draft' as const, label: 'Taslak' },
		{ value: 'sent' as const, label: 'Gönderildi' },
		{ value: 'accepted' as const, label: 'Kabul' },
		{ value: 'rejected' as const, label: 'Reddedildi' },
		{ value: 'expired' as const, label: 'Süresi Doldu' }
	];

	const columns = [
		{
			key: 'quoteNumber' as const,
			label: 'Teklif No',
			sortable: true,
			width: '12%'
		},
		{
			key: 'customerName' as const,
			label: 'Müşteri',
			sortable: true,
			width: '18%'
		},
		{
			key: 'amount' as const,
			label: 'Tutar (₺)',
			sortable: true,
			width: '15%',
			format: (value: number) => {
				return new Intl.NumberFormat('tr-TR', {
					style: 'currency',
					currency: 'TRY'
				}).format(value);
			}
		},
		{
			key: 'tax' as const,
			label: 'KDV (₺)',
			sortable: true,
			width: '12%',
			format: (value: number) => {
				return new Intl.NumberFormat('tr-TR', {
					style: 'currency',
					currency: 'TRY'
				}).format(value);
			}
		},
		{
			key: 'total' as const,
			label: 'Toplam (₺)',
			sortable: true,
			width: '15%',
			format: (value: number) => {
				return new Intl.NumberFormat('tr-TR', {
					style: 'currency',
					currency: 'TRY'
				}).format(value);
			}
		},
		{
			key: 'status' as const,
			label: 'Durum',
			sortable: true,
			width: '12%',
			format: (value: QuoteStatus) => {
				const statusMap: Record<QuoteStatus, string> = {
					draft: 'Taslak',
					sent: 'Gönderildi',
					accepted: 'Kabul',
					rejected: 'Reddedildi',
					expired: 'Süresi Doldu'
				};
				return statusMap[value] || value;
			}
		},
		{
			key: 'validUntil' as const,
			label: 'Vade Tarihi',
			sortable: true,
			width: '16%',
			format: (value: string) => {
				return new Date(value).toLocaleDateString('tr-TR');
			}
		}
	];

	onMount(async () => {
		await quoteStore.loadAll();
		isLoading = false;
	});

	function openCreateModal() {
		editingId = null;
		formData = {
			quoteNumber: '',
			customerName: '',
			amount: 0,
			tax: 0,
			total: 0,
			description: '',
			notes: '',
			status: 'draft',
			validUntil: new Date().toISOString().split('T')[0]
		};
		showModal = true;
	}

	async function openEditModal(quote: Quote) {
		editingId = quote.id;
		formData = { ...quote };
		showModal = true;
	}

	async function handleSave() {
		if (!formData.quoteNumber.trim() || !formData.customerName.trim()) {
			toastStore.addToast({
				type: 'error',
				title: 'Hata',
				message: 'Teklif no ve müşteri adı gereklidir.'
			});
			return;
		}

		isSaving = true;

		try {
			// Calculate total
			const total = formData.amount + formData.tax;

			const quoteData = {
				...formData,
				total
			};

			if (editingId) {
				await quoteStore.updateQuote(editingId, quoteData);
				toastStore.addToast({
					type: 'success',
					title: 'Başarılı',
					message: 'Teklif güncellendi.'
				});
			} else {
				await quoteStore.addQuote(quoteData);
				toastStore.addToast({
					type: 'success',
					title: 'Başarılı',
					message: 'Teklif oluşturuldu.'
				});
			}
			showModal = false;
			formData = {
				quoteNumber: '',
				customerName: '',
				amount: 0,
				tax: 0,
				total: 0,
				description: '',
				notes: '',
				status: 'draft',
				validUntil: new Date().toISOString().split('T')[0]
			};
		} catch (error) {
			toastStore.addToast({
				type: 'error',
				title: 'Hata',
				message: error instanceof Error ? error.message : 'Bilinmeyen hata oluştu'
			});
		} finally {
			isSaving = false;
		}
	}

	async function handleDelete(quote: Quote) {
		if (!confirm(`${quote.quoteNumber} silinsin mi?`)) return;

		try {
			await quoteStore.deleteQuote(quote.id);
			toastStore.addToast({
				type: 'success',
				title: 'Başarılı',
				message: 'Teklif silindi.'
			});
		} catch (error) {
			toastStore.addToast({
				type: 'error',
				title: 'Hata',
				message: error instanceof Error ? error.message : 'Silme işlemi başarısız'
			});
		}
	}

	async function exportQuotesPDF() {
		try {
			const { exportQuotePDF } = await import('#lib/services/pdfService');

			if (selectedItems.size > 0) {
				for (const quote of selectedItems) {
					exportQuotePDF(quote);
				}
				toastStore.addToast({
					type: 'success',
					title: 'Başarılı',
					message: `${selectedItems.size} teklif PDF olarak indirildi.`
				});
			} else {
				toastStore.addToast({
					type: 'warning',
					title: 'Uyarı',
					message: 'Lütfen PDF olarak indirmek için teklif seçin.'
				});
			}
		} catch (error) {
			toastStore.addToast({
				type: 'error',
				title: 'Hata',
				message: 'PDF oluşturma başarısız'
			});
		}
	}

	let filteredQuotes = $derived.by(() => {
		const q = searchQuery.toLowerCase();
		return $quoteStore.items.filter((quote) => {
			const matchesSearch =
				quote.quoteNumber.toLowerCase().includes(q) ||
				quote.customerName.toLowerCase().includes(q) ||
				quote.description?.toLowerCase().includes(q);
			const matchesStatus = statusFilter === 'all' || quote.status === statusFilter;
			return matchesSearch && matchesStatus;
		});
	});
</script>

<PageContainer title="Teklifler - Tablo Görünümü">
	<div class="controls">
		<div class="search-bar">
			<Search size={18} />
			<Input
				type="text"
				placeholder="Teklif ara..."
				bind:value={searchQuery}
				class="search-input"
			/>
		</div>

		<Select bind:value={statusFilter} options={statusOptions} label="Durum:" />

		<div class="actions">
			{#if selectedItems.size > 0}
				<span class="selection-info">{selectedItems.size} seçildi</span>
			{/if}

			<Button variant="primary" on:click={openCreateModal}>
				<Plus size={18} />
				Yeni Teklif
			</Button>

			{#if selectedItems.size > 0}
				<Button variant="secondary" on:click={exportQuotesPDF} disabled={isSaving}>
					<Download size={18} />
					PDF İndir ({selectedItems.size})
				</Button>
			{/if}
		</div>
	</div>

	{#if isLoading}
		<div class="loading">Yükleniyor...</div>
	{:else}
		<Table
			data={filteredQuotes}
			{columns}
			selectable={true}
			hoverable={true}
			striped={true}
			onEdit={openEditModal}
			onDelete={handleDelete}
			bind:selectedItems
			onSelectionChange={(items) => {
				selectedItems = items;
			}}
		/>
	{/if}

	{#if showModal}
		<Modal
			title={editingId ? 'Teklif Düzenle' : 'Yeni Teklif'}
			on:close={() => (showModal = false)}
		>
			<div class="form-grid">
				<Input
					label="Teklif No"
					type="text"
					bind:value={formData.quoteNumber}
					required
					placeholder="T-001"
				/>
				<Input
					label="Müşteri Adı"
					type="text"
					bind:value={formData.customerName}
					required
					placeholder="Müşteri adı"
				/>
				<Input
					label="Tutar (₺)"
					type="number"
					bind:value={formData.amount}
					placeholder="0"
				/>
				<Input
					label="KDV (₺)"
					type="number"
					bind:value={formData.tax}
					placeholder="0"
				/>
				<Select
					label="Durum"
					bind:value={formData.status}
					options={statusOptions.filter((o) => o.value !== 'all')}
				/>
				<Input
					label="Vade Tarihi"
					type="date"
					bind:value={formData.validUntil}
				/>
			</div>

			<TextArea
				label="Açıklama"
				bind:value={formData.description}
				placeholder="Teklif açıklaması..."
				rows={3}
			/>

			<TextArea
				label="Notlar"
				bind:value={formData.notes}
				placeholder="Teklif hakkında notlar..."
				rows={3}
			/>

			{#if formData.amount > 0 || formData.tax > 0}
				<div class="total-display">
					<div class="total-line">
						<span>Ara Toplam:</span>
						<span>{new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(formData.amount)}</span>
					</div>
					<div class="total-line">
						<span>KDV (%20):</span>
						<span>{new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(formData.tax)}</span>
					</div>
					<div class="total-line final">
						<span>GENEL TOPLAM:</span>
						<span>{new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(formData.amount + formData.tax)}</span>
					</div>
				</div>
			{/if}

			<div class="modal-actions">
				<Button variant="secondary" on:click={() => (showModal = false)}>İptal</Button>
				<Button variant="primary" on:click={handleSave} disabled={isSaving}>
					{isSaving ? 'Kaydediliyor...' : 'Kaydet'}
				</Button>
			</div>
		</Modal>
	{/if}

	<Toast notifications={$toastStore} />
</PageContainer>

<style>
	.controls {
		display: flex;
		gap: var(--spacing-4);
		margin-bottom: var(--spacing-6);
		flex-wrap: wrap;
		align-items: center;
	}

	.search-bar {
		display: flex;
		align-items: center;
		gap: var(--spacing-2);
		flex: 1;
		min-width: 250px;
		background: var(--color-bg-secondary);
		padding: 0 var(--spacing-3);
		border-radius: var(--radius-md);
		border: 1px solid var(--color-border);
	}

	.search-bar :global(.search-input) {
		background: transparent;
		border: none;
	}

	.actions {
		display: flex;
		gap: var(--spacing-2);
		flex-wrap: wrap;
		align-items: center;
	}

	.selection-info {
		font-size: var(--text-sm);
		color: var(--color-text-secondary);
		font-weight: 600;
		padding: 0 var(--spacing-2);
	}

	.form-grid {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: var(--spacing-4);
		margin-bottom: var(--spacing-4);
	}

	.total-display {
		background: var(--color-bg-secondary);
		padding: var(--spacing-4);
		border-radius: var(--radius-md);
		margin: var(--spacing-4) 0;
		border-left: 4px solid var(--color-primary);
	}

	.total-line {
		display: flex;
		justify-content: space-between;
		padding: var(--spacing-2) 0;
		font-size: var(--text-sm);
		border-bottom: 1px solid var(--color-border);
	}

	.total-line.final {
		border-bottom: none;
		border-top: 2px solid var(--color-primary);
		padding-top: var(--spacing-3);
		font-weight: 700;
		color: var(--color-primary);
		font-size: var(--text-base);
	}

	.modal-actions {
		display: flex;
		gap: var(--spacing-2);
		justify-content: flex-end;
		margin-top: var(--spacing-6);
	}

	.loading {
		text-align: center;
		padding: var(--spacing-8);
		color: var(--color-text-secondary);
	}

	@media (max-width: 768px) {
		.controls {
			flex-direction: column;
		}

		.search-bar {
			flex: 1;
			width: 100%;
		}

		.actions {
			width: 100%;
		}

		.form-grid {
			grid-template-columns: 1fr;
		}
	}
</style>
