<script lang="ts">
	import { onMount } from 'svelte';
	import { customerStore } from '#lib/stores/customerStore';
	import { toastStore } from '#lib/stores/toastStore';
	import Table from '#lib/components/Table.svelte';
	import Button from '#lib/components/Button.svelte';
	import Input from '#lib/components/Form/Input.svelte';
	import Modal from '#lib/components/Modal.svelte';
	import Toast from '#lib/components/Toast.svelte';
	import PageContainer from '#lib/components/Layout/PageContainer.svelte';
	import { Download, Plus, Search } from 'lucide-svelte';
	import type { Customer } from '#lib/types/models';

	let isLoading = $state(true);
	let isSaving = $state(false);
	let showModal = $state(false);
	let editingId = $state<string | null>(null);
	let searchQuery = $state('');
	let selectedItems = $state(new Set<Customer>());

	let formData = $state({
		name: '',
		phone: '',
		email: '',
		address: '',
		city: '',
		notes: ''
	});

	const columns = [
		{
			key: 'name' as const,
			label: 'Ad / Firma',
			sortable: true,
			width: '25%'
		},
		{
			key: 'phone' as const,
			label: 'Telefon',
			sortable: true,
			width: '15%'
		},
		{
			key: 'email' as const,
			label: 'E-posta',
			sortable: true,
			width: '20%'
		},
		{
			key: 'address' as const,
			label: 'Adres',
			sortable: false,
			width: '25%'
		},
		{
			key: 'city' as const,
			label: 'Şehir',
			sortable: true,
			width: '15%'
		}
	];

	onMount(async () => {
		await customerStore.loadAll();
		isLoading = false;
	});

	function openCreateModal() {
		editingId = null;
		formData = {
			name: '',
			phone: '',
			email: '',
			address: '',
			city: '',
			notes: ''
		};
		showModal = true;
	}

	async function openEditModal(customer: Customer) {
		editingId = customer.id;
		formData = { ...customer };
		showModal = true;
	}

	async function handleSave() {
		if (!formData.name.trim()) {
			toastStore.addToast({
				type: 'error',
				title: 'Hata',
				message: 'Müşteri adı gereklidir.'
			});
			return;
		}

		isSaving = true;

		try {
			if (editingId) {
				await customerStore.updateCustomer(editingId, formData);
				toastStore.addToast({
					type: 'success',
					title: 'Başarılı',
					message: 'Müşteri bilgileri güncellendi.'
				});
			} else {
				await customerStore.addCustomer(formData);
				toastStore.addToast({
					type: 'success',
					title: 'Başarılı',
					message: 'Müşteri başarıyla oluşturuldu.'
				});
			}
			showModal = false;
			formData = {
				name: '',
				phone: '',
				email: '',
				address: '',
				city: '',
				notes: ''
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

	async function handleDelete(customer: Customer) {
		if (!confirm(`${customer.name} silinsin mi?`)) return;

		try {
			await customerStore.deleteCustomer(customer.id);
			toastStore.addToast({
				type: 'success',
				title: 'Başarılı',
				message: 'Müşteri silindi.'
			});
		} catch (error) {
			toastStore.addToast({
				type: 'error',
				title: 'Hata',
				message: error instanceof Error ? error.message : 'Silme işlemi başarısız'
			});
		}
	}

	async function handleBulkDelete() {
		if (selectedItems.size === 0) {
			toastStore.addToast({
				type: 'warning',
				title: 'Uyarı',
				message: 'Lütfen silmek için müşteri seçin.'
			});
			return;
		}

		if (!confirm(`${selectedItems.size} müşteri silinsin mi?`)) return;

		try {
			for (const customer of selectedItems) {
				await customerStore.deleteCustomer(customer.id);
			}
			selectedItems.clear();
			toastStore.addToast({
				type: 'success',
				title: 'Başarılı',
				message: `${selectedItems.size} müşteri silindi.`
			});
		} catch (error) {
			toastStore.addToast({
				type: 'error',
				title: 'Hata',
				message: 'Toplu silme işlemi başarısız'
			});
		}
	}

	async function exportCustomerListPDF() {
		try {
			const { exportCustomerListPDF } = await import('#lib/services/pdfService');
			exportCustomerListPDF($customerStore.items);
			toastStore.addToast({
				type: 'success',
				title: 'Başarılı',
				message: 'Müşteri listesi PDF olarak indirildi.'
			});
		} catch (error) {
			toastStore.addToast({
				type: 'error',
				title: 'Hata',
				message: 'PDF oluşturma başarısız'
			});
		}
	}

	let filteredCustomers = $derived.by(() => {
		const q = searchQuery.toLowerCase();
		return $customerStore.items.filter(
			(c) =>
				c.name.toLowerCase().includes(q) ||
				c.email?.toLowerCase().includes(q) ||
				c.phone?.includes(q)
		);
	});
</script>

<PageContainer title="Müşteriler - Tablo Görünümü">
	<div class="controls">
		<div class="search-bar">
			<Search size={18} />
			<Input
				type="text"
				placeholder="Müşteri ara..."
				bind:value={searchQuery}
				class="search-input"
			/>
		</div>

		<div class="actions">
			{#if selectedItems.size > 0}
				<span class="selection-info">{selectedItems.size} seçildi</span>
				<Button variant="danger" on:click={handleBulkDelete} disabled={isSaving}>
					Seçilenleri Sil ({selectedItems.size})
				</Button>
			{/if}

			<Button variant="primary" on:click={openCreateModal}>
				<Plus size={18} />
				Yeni Müşteri
			</Button>

			<Button variant="secondary" on:click={exportCustomerListPDF} disabled={isLoading}>
				<Download size={18} />
				PDF İndir
			</Button>
		</div>
	</div>

	{#if isLoading}
		<div class="loading">Yükleniyor...</div>
	{:else}
		<Table
			data={filteredCustomers}
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
			title={editingId ? 'Müşteri Düzenle' : 'Yeni Müşteri'}
			on:close={() => (showModal = false)}
		>
			<div class="form-grid">
				<Input
					label="Ad / Firma"
					type="text"
					bind:value={formData.name}
					required
					placeholder="Müşteri adı"
				/>
				<Input
					label="Telefon"
					type="tel"
					bind:value={formData.phone}
					placeholder="0555 000 0000"
				/>
				<Input
					label="E-posta"
					type="email"
					bind:value={formData.email}
					placeholder="ornek@example.com"
				/>
				<Input label="Şehir" type="text" bind:value={formData.city} placeholder="Şehir" />
			</div>

			<Input label="Adres" type="text" bind:value={formData.address} placeholder="Adres" />

			<TextArea
				label="Notlar"
				bind:value={formData.notes}
				placeholder="Müşteri hakkında notlar..."
				rows={4}
			/>

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
