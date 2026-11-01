<script lang="ts">
	import { onMount } from 'svelte';
	import { projectStore } from '#lib/stores/projectStore';
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
	import type { Project, ProjectStatus } from '#lib/types/models';
	import { PROJECT_STATUSES, statusInfo } from '#lib/workflow';

	let isLoading = $state(true);
	let isSaving = $state(false);
	let showModal = $state(false);
	let editingId = $state<string | null>(null);
	let searchQuery = $state('');
	let statusFilter = $state<ProjectStatus | 'all'>('all');
	let selectedItems = $state(new Set<Project>());

	let formData = $state({
		name: '',
		description: '',
		status: 'OLCULDU' as ProjectStatus,
		budget: 0,
		timeline: 0,
		notes: ''
	});

	const statusOptions = [
		{ value: 'all' as const, label: 'Tüm Projeler' },
		...PROJECT_STATUSES.map((s) => ({ value: s.code, label: s.label }))
	];

	const columns = [
		{
			key: 'name' as const,
			label: 'Proje Adı',
			sortable: true,
			width: '25%'
		},
		{
			key: 'status' as const,
			label: 'Durum',
			sortable: true,
			width: '15%',
			format: (value: ProjectStatus) => statusInfo(value).label
		},
		{
			key: 'budget' as const,
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
			key: 'timeline' as const,
			label: 'Zaman (gün)',
			sortable: true,
			width: '15%'
		},
		{
			key: 'description' as const,
			label: 'Açıklama',
			sortable: false,
			width: '30%'
		}
	];

	onMount(async () => {
		await projectStore.loadAll();
		isLoading = false;
	});

	function openCreateModal() {
		editingId = null;
		formData = {
			name: '',
			description: '',
			status: 'OLCULDU',
			budget: 0,
			timeline: 0,
			notes: ''
		};
		showModal = true;
	}

	async function openEditModal(project: Project) {
		editingId = project.id;
		formData = { ...project };
		showModal = true;
	}

	async function handleSave() {
		if (!formData.name.trim()) {
			toastStore.addToast({
				type: 'error',
				title: 'Hata',
				message: 'Proje adı gereklidir.'
			});
			return;
		}

		isSaving = true;

		try {
			if (editingId) {
				await projectStore.updateProject(editingId, formData);
				toastStore.addToast({
					type: 'success',
					title: 'Başarılı',
					message: 'Proje güncellendi.'
				});
			} else {
				await projectStore.addProject(formData);
				toastStore.addToast({
					type: 'success',
					title: 'Başarılı',
					message: 'Proje oluşturuldu.'
				});
			}
			showModal = false;
			formData = {
				name: '',
				description: '',
				status: 'OLCULDU',
				budget: 0,
				timeline: 0,
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

	async function handleDelete(project: Project) {
		if (!confirm(`${project.name} silinsin mi?`)) return;

		try {
			await projectStore.deleteProject(project.id);
			toastStore.addToast({
				type: 'success',
				title: 'Başarılı',
				message: 'Proje silindi.'
			});
		} catch (error) {
			toastStore.addToast({
				type: 'error',
				title: 'Hata',
				message: error instanceof Error ? error.message : 'Silme işlemi başarısız'
			});
		}
	}

	async function exportProjectsPDF() {
		try {
			const { exportProjectReportPDF } = await import('#lib/services/pdfService');

			// Export the first selected project or all visible projects
			if (selectedItems.size > 0) {
				for (const project of selectedItems) {
					exportProjectReportPDF(project);
				}
				toastStore.addToast({
					type: 'success',
					title: 'Başarılı',
					message: `${selectedItems.size} proje raporu PDF olarak indirildi.`
				});
			} else {
				toastStore.addToast({
					type: 'warning',
					title: 'Uyarı',
					message: 'Lütfen PDF olarak indirmek için proje seçin.'
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

	let filteredProjects = $derived.by(() => {
		const q = searchQuery.toLowerCase();
		return $projectStore.items.filter((p) => {
			const matchesSearch = p.name.toLowerCase().includes(q) ||
				p.description?.toLowerCase().includes(q);
			const matchesStatus = statusFilter === 'all' || p.status === statusFilter;
			return matchesSearch && matchesStatus;
		});
	});
</script>

<PageContainer title="Projeler - Tablo Görünümü">
	<div class="controls">
		<div class="search-bar">
			<Search size={18} />
			<Input
				type="text"
				placeholder="Proje ara..."
				bind:value={searchQuery}
				class="search-input"
			/>
		</div>

		<Select bind:value={statusFilter} options={statusOptions} label="Durum:" />

		<div class="actions">
			{#if selectedItems.size > 0}
				<span class="selection-info">{selectedItems.size} seçildi</span>
			{/if}

			<Button variant="primary" onclick={openCreateModal}>
				<Plus size={18} />
				Yeni Proje
			</Button>

			{#if selectedItems.size > 0}
				<Button variant="secondary" onclick={exportProjectsPDF} disabled={isSaving}>
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
			data={filteredProjects}
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
			title={editingId ? 'Proje Düzenle' : 'Yeni Proje'}
			onclose={() => (showModal = false)}
		>
			<div class="form-grid">
				<Input
					label="Proje Adı"
					type="text"
					bind:value={formData.name}
					required
					placeholder="Proje adı"
				/>
				<Select
					label="Durum"
					bind:value={formData.status}
					options={statusOptions.filter((o) => o.value !== 'all')}
				/>
				<Input
					label="Bütçe (₺)"
					type="number"
					bind:value={formData.budget}
					placeholder="0"
				/>
				<Input
					label="Zaman Çizelgesi (gün)"
					type="number"
					bind:value={formData.timeline}
					placeholder="0"
				/>
			</div>

			<TextArea
				label="Açıklama"
				bind:value={formData.description}
				placeholder="Proje açıklaması..."
				rows={3}
			/>

			<TextArea
				label="Notlar"
				bind:value={formData.notes}
				placeholder="Proje hakkında notlar..."
				rows={3}
			/>

			<div class="modal-actions">
				<Button variant="secondary" onclick={() => (showModal = false)}>İptal</Button>
				<Button variant="primary" onclick={handleSave} disabled={isSaving}>
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
