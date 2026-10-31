<script lang="ts">
	import { onMount } from 'svelte';
	import { supabase } from '#lib/supabase';
	import { ChevronLeft, Plus, X, Save } from '@lucide/svelte';

	interface Material {
		id?: string;
		name: string;
		quantity: number;
		unit: string;
		unit_cost: number;
	}

	interface Worker {
		id?: string;
		name: string;
		role: string;
		hours: number;
		hourly_rate: number;
	}

	interface MontageDetails {
		workers: Worker[];
		materials: Material[];
		labor_cost: number;
		material_cost: number;
		notes: string;
	}

	let projectKey = '';
	let activeTab: 'overview' | 'materials' | 'workers' | 'report' = $state('overview');
	let loading = $state(true);
	let saving = $state(false);

	let projectData: any = $state(null);
	let montageData: MontageDetails = $state({
		workers: [],
		materials: [],
		labor_cost: 0,
		material_cost: 0,
		notes: ''
	});

	let editingMaterial: Partial<Material> | null = null;
	let editingWorker: Partial<Worker> | null = null;

	// Form states
	let newMaterial: Material = $state({
		name: '',
		quantity: 0,
		unit: 'adet',
		unit_cost: 0
	});

	let newWorker: Worker = $state({
		name: '',
		role: '',
		hours: 0,
		hourly_rate: 0
	});

	onMount(async () => {
		projectKey = window.location.pathname.split('/')[2];
		await loadProjectData();
	});

	async function loadProjectData() {
		try {
			loading = true;
			const response = await fetch(`/api/projects/${projectKey}`);
			const result = await response.json();

			if (result.data) {
				projectData = result.data;
				if (result.data.data?.montage_details) {
					montageData = result.data.data.montage_details;
				}
			}
		} catch (error) {
			console.error('Error loading project:', error);
		} finally {
			loading = false;
		}
	}

	function calculateMaterialCost() {
		montageData.material_cost = montageData.materials.reduce(
			(sum, m) => sum + m.quantity * m.unit_cost,
			0
		);
	}

	function calculateLaborCost() {
		montageData.labor_cost = montageData.workers.reduce(
			(sum, w) => sum + w.hours * w.hourly_rate,
			0
		);
	}

	function addMaterial() {
		if (newMaterial.name && newMaterial.quantity > 0 && newMaterial.unit_cost > 0) {
			montageData.materials = [
				...montageData.materials,
				{ ...newMaterial, id: Date.now().toString() }
			];
			calculateMaterialCost();
			newMaterial = { name: '', quantity: 0, unit: 'adet', unit_cost: 0 };
		}
	}

	function removeMaterial(id: string | undefined) {
		if (id) {
			montageData.materials = montageData.materials.filter((m) => m.id !== id);
			calculateMaterialCost();
		}
	}

	function addWorker() {
		if (newWorker.name && newWorker.role && newWorker.hours > 0 && newWorker.hourly_rate > 0) {
			montageData.workers = [
				...montageData.workers,
				{ ...newWorker, id: Date.now().toString() }
			];
			calculateLaborCost();
			newWorker = { name: '', role: '', hours: 0, hourly_rate: 0 };
		}
	}

	function removeWorker(id: string | undefined) {
		if (id) {
			montageData.workers = montageData.workers.filter((w) => w.id !== id);
			calculateLaborCost();
		}
	}

	async function saveMontageDetails() {
		try {
			saving = true;

			const response = await fetch(`/api/projects/${projectKey}`, {
				method: 'PUT',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ montage_details: montageData })
			});

			if (response.ok) {
				alert('Montaj detayları kaydedildi!');
			} else {
				alert('Hata: Veriler kaydedilemedi');
			}
		} catch (error) {
			console.error('Error saving:', error);
			alert('Kaydetme sırasında hata oluştu');
		} finally {
			saving = false;
		}
	}

	function goToReport() {
		window.location.href = `/montage/${projectKey}/report`;
	}

	function goToDaily() {
		window.location.href = `/montage/${projectKey}/daily`;
	}

	function formatCurrency(value: number) {
		return new Intl.NumberFormat('tr-TR', {
			style: 'currency',
			currency: 'TRY'
		}).format(value);
	}
</script>

<div class="container">
	<div class="header">
		<a href="/montage" class="back-btn">
			<ChevronLeft size={20} />
		</a>
		<h1>Montaj Detayları</h1>
		<div class="header-actions">
			<button class="btn btn-primary" on:click={saveMontageDetails} disabled={saving}>
				<Save size={18} />
				{saving ? 'Kaydediliyor...' : 'Kaydet'}
			</button>
		</div>
	</div>

	{#if loading}
		<div class="loading">Yükleniyor...</div>
	{:else}
		<div class="tabs">
			<button
				class="tab {activeTab === 'overview' ? 'active' : ''}"
				on:click={() => (activeTab = 'overview')}
			>
				Özet
			</button>
			<button
				class="tab {activeTab === 'materials' ? 'active' : ''}"
				on:click={() => (activeTab = 'materials')}
			>
				Malzeme
			</button>
			<button
				class="tab {activeTab === 'workers' ? 'active' : ''}"
				on:click={() => (activeTab = 'workers')}
			>
				İşçiler
			</button>
			<button
				class="tab {activeTab === 'report' ? 'active' : ''}"
				on:click={() => (activeTab = 'report')}
			>
				Rapor
			</button>
		</div>

		<div class="content">
			<!-- ÖZET TAB -->
			{#if activeTab === 'overview'}
				<div class="tab-content">
					<div class="overview-grid">
						<div class="stat-card">
							<div class="stat-label">Toplam Malzeme Maliyeti</div>
							<div class="stat-value">{formatCurrency(montageData.material_cost)}</div>
						</div>
						<div class="stat-card">
							<div class="stat-label">Toplam İşçilik Maliyeti</div>
							<div class="stat-value">{formatCurrency(montageData.labor_cost)}</div>
						</div>
						<div class="stat-card highlight">
							<div class="stat-label">Toplam Maliyet</div>
							<div class="stat-value">
								{formatCurrency(montageData.material_cost + montageData.labor_cost)}
							</div>
						</div>
					</div>

					<div class="form-section">
						<h3>Notlar</h3>
						<textarea
							placeholder="Montaj ile ilgili notlar..."
							bind:value={montageData.notes}
							rows="6"
						></textarea>
					</div>

					<div class="info-grid">
						<div class="info-item">
							<strong>Proje:</strong>
							<span>{projectData?.data?.name || projectData?.data?.project_name || 'N/A'}</span>
						</div>
						<div class="info-item">
							<strong>Müşteri:</strong>
							<span>{projectData?.data?.customer || projectData?.data?.customer_name || 'N/A'}</span>
						</div>
						<div class="info-item">
							<strong>Sistem:</strong>
							<span>{projectData?.data?.system_name || 'N/A'}</span>
						</div>
						<div class="info-item">
							<strong>Oluşturma Tarihi:</strong>
							<span>
								{projectData?.created_at
									? new Date(projectData.created_at).toLocaleDateString('tr-TR')
									: 'N/A'}
							</span>
						</div>
					</div>
				</div>
			{/if}

			<!-- MALZEME TAB -->
			{#if activeTab === 'materials'}
				<div class="tab-content">
					<div class="form-section">
						<h3>Yeni Malzeme Ekle</h3>
						<div class="form-grid">
							<input
								type="text"
								placeholder="Malzeme adı"
								bind:value={newMaterial.name}
								class="input"
							/>
							<input
								type="number"
								placeholder="Miktar"
								bind:value={newMaterial.quantity}
								class="input"
								min="0"
								step="0.1"
							/>
							<input type="text" placeholder="Birim" bind:value={newMaterial.unit} class="input" />
							<input
								type="number"
								placeholder="Birim Fiyatı"
								bind:value={newMaterial.unit_cost}
								class="input"
								min="0"
								step="0.01"
							/>
							<button class="btn btn-primary" on:click={addMaterial}>
								<Plus size={18} />
								Ekle
							</button>
						</div>
					</div>

					<div class="table-section">
						<h3>Malzeme Listesi</h3>
						{#if montageData.materials.length > 0}
							<table class="data-table">
								<thead>
									<tr>
										<th>Malzeme</th>
										<th>Miktar</th>
										<th>Birim</th>
										<th>Birim Fiyatı</th>
										<th>Toplam</th>
										<th>İşlem</th>
									</tr>
								</thead>
								<tbody>
									{#each montageData.materials as material (material.id)}
										<tr>
											<td>{material.name}</td>
											<td class="number">{material.quantity}</td>
											<td>{material.unit}</td>
											<td class="number">{formatCurrency(material.unit_cost)}</td>
											<td class="number">
												{formatCurrency(material.quantity * material.unit_cost)}
											</td>
											<td>
												<button
													class="btn btn-sm btn-danger"
													on:click={() => removeMaterial(material.id)}
												>
													<X size={16} />
												</button>
											</td>
										</tr>
									{/each}
								</tbody>
								<tfoot>
									<tr>
										<td colspan="4" class="text-right"><strong>Toplam:</strong></td>
										<td class="number"><strong>{formatCurrency(montageData.material_cost)}</strong></td>
										<td></td>
									</tr>
								</tfoot>
							</table>
						{:else}
							<p class="empty-state">Henüz malzeme eklenmemiş</p>
						{/if}
					</div>
				</div>
			{/if}

			<!-- İŞÇİLER TAB -->
			{#if activeTab === 'workers'}
				<div class="tab-content">
					<div class="form-section">
						<h3>Yeni İşçi Ekle</h3>
						<div class="form-grid">
							<input
								type="text"
								placeholder="İşçi adı"
								bind:value={newWorker.name}
								class="input"
							/>
							<input
								type="text"
								placeholder="Pozisyon/Rol"
								bind:value={newWorker.role}
								class="input"
							/>
							<input
								type="number"
								placeholder="Çalışma Saati"
								bind:value={newWorker.hours}
								class="input"
								min="0"
								step="0.5"
							/>
							<input
								type="number"
								placeholder="Saatlik Ücret"
								bind:value={newWorker.hourly_rate}
								class="input"
								min="0"
								step="0.01"
							/>
							<button class="btn btn-primary" on:click={addWorker}>
								<Plus size={18} />
								Ekle
							</button>
						</div>
					</div>

					<div class="table-section">
						<h3>İşçi Listesi</h3>
						{#if montageData.workers.length > 0}
							<table class="data-table">
								<thead>
									<tr>
										<th>Ad/Soyad</th>
										<th>Pozisyon</th>
										<th>Saat</th>
										<th>Saatlik Ücret</th>
										<th>Toplam Ücret</th>
										<th>İşlem</th>
									</tr>
								</thead>
								<tbody>
									{#each montageData.workers as worker (worker.id)}
										<tr>
											<td>{worker.name}</td>
											<td>{worker.role}</td>
											<td class="number">{worker.hours}</td>
											<td class="number">{formatCurrency(worker.hourly_rate)}</td>
											<td class="number">
												{formatCurrency(worker.hours * worker.hourly_rate)}
											</td>
											<td>
												<button
													class="btn btn-sm btn-danger"
													on:click={() => removeWorker(worker.id)}
												>
													<X size={16} />
												</button>
											</td>
										</tr>
									{/each}
								</tbody>
								<tfoot>
									<tr>
										<td colspan="4" class="text-right"><strong>Toplam:</strong></td>
										<td class="number"><strong>{formatCurrency(montageData.labor_cost)}</strong></td>
										<td></td>
									</tr>
								</tfoot>
							</table>
						{:else}
							<p class="empty-state">Henüz işçi eklenmemiş</p>
						{/if}
					</div>
				</div>
			{/if}

			<!-- RAPOR TAB -->
			{#if activeTab === 'report'}
				<div class="tab-content">
					<div class="report-preview">
						<h3>Müşteri Raporu Önizlemesi</h3>
						<p class="info-text">
							Aşağıdaki düğme ile yazdırılabilir raporu açabilir ve indrebilirsiniz.
						</p>
						<button class="btn btn-primary" on:click={goToReport}>
							Raporyu Aç
						</button>
					</div>

					<div class="quick-summary">
						<h3>Hızlı Özet</h3>
						<div class="summary-grid">
							<div class="summary-item">
								<div class="summary-label">Malzeme Sayısı</div>
								<div class="summary-value">{montageData.materials.length}</div>
							</div>
							<div class="summary-item">
								<div class="summary-label">İşçi Sayısı</div>
								<div class="summary-value">{montageData.workers.length}</div>
							</div>
							<div class="summary-item">
								<div class="summary-label">Toplam Malzeme Maliyeti</div>
								<div class="summary-value">{formatCurrency(montageData.material_cost)}</div>
							</div>
							<div class="summary-item">
								<div class="summary-label">Toplam İşçilik Maliyeti</div>
								<div class="summary-value">{formatCurrency(montageData.labor_cost)}</div>
							</div>
						</div>
					</div>
				</div>
			{/if}
		</div>

		<div class="footer-actions">
			<button class="btn btn-outline" on:click={goToDaily}>Gün Takibine Git</button>
			<button class="btn btn-primary" on:click={saveMontageDetails} disabled={saving}>
				<Save size={18} />
				{saving ? 'Kaydediliyor...' : 'Tüm Değişiklikleri Kaydet'}
			</button>
		</div>
	{/if}
</div>

<style>
	.container {
		max-width: 1200px;
		margin: 0 auto;
		padding: 1.5rem;
		background: #fff;
		min-height: 100vh;
	}

	.header {
		display: flex;
		align-items: center;
		gap: 1rem;
		margin-bottom: 2rem;
		padding-bottom: 1.5rem;
		border-bottom: 2px solid #e0e0e0;
	}

	.header h1 {
		flex: 1;
		margin: 0;
		font-size: 1.75rem;
		color: #333;
	}

	.header-actions {
		display: flex;
		gap: 0.5rem;
	}

	.back-btn {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 40px;
		height: 40px;
		border-radius: 8px;
		background: #f5f5f5;
		color: #333;
		border: none;
		cursor: pointer;
		transition: background 0.2s;
	}

	.back-btn:hover {
		background: #e0e0e0;
	}

	.tabs {
		display: flex;
		gap: 0;
		margin-bottom: 2rem;
		border-bottom: 1px solid #e0e0e0;
		overflow-x: auto;
	}

	.tab {
		padding: 1rem 1.5rem;
		background: none;
		border: none;
		border-bottom: 3px solid transparent;
		color: #666;
		font-size: 0.95rem;
		font-weight: 500;
		cursor: pointer;
		transition: all 0.2s;
	}

	.tab:hover {
		color: #0f7c80;
		background: #f9f9f9;
	}

	.tab.active {
		color: #0f7c80;
		border-bottom-color: #0f7c80;
	}

	.content {
		margin-bottom: 2rem;
	}

	.tab-content {
		animation: fadeIn 0.2s;
	}

	@keyframes fadeIn {
		from {
			opacity: 0;
		}
		to {
			opacity: 1;
		}
	}

	.overview-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
		gap: 1.5rem;
		margin-bottom: 2rem;
	}

	.stat-card {
		padding: 1.5rem;
		background: #f9f9f9;
		border-radius: 8px;
		border: 1px solid #e0e0e0;
	}

	.stat-card.highlight {
		background: #0f7c80;
		color: white;
		border-color: #0f7c80;
	}

	.stat-label {
		font-size: 0.9rem;
		color: #666;
		margin-bottom: 0.5rem;
	}

	.stat-card.highlight .stat-label {
		color: rgba(255, 255, 255, 0.8);
	}

	.stat-value {
		font-size: 1.75rem;
		font-weight: bold;
		color: #0f7c80;
	}

	.stat-card.highlight .stat-value {
		color: white;
	}

	.form-section {
		background: #f9f9f9;
		padding: 1.5rem;
		border-radius: 8px;
		margin-bottom: 2rem;
	}

	.form-section h3 {
		margin: 0 0 1rem 0;
		font-size: 1.1rem;
		color: #333;
	}

	.form-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
		gap: 1rem;
		align-items: end;
	}

	.input {
		padding: 0.75rem;
		border: 1px solid #ddd;
		border-radius: 6px;
		font-size: 0.95rem;
		font-family: inherit;
		transition: border-color 0.2s;
	}

	.input:focus {
		outline: none;
		border-color: #0f7c80;
		box-shadow: 0 0 0 2px rgba(15, 124, 128, 0.1);
	}

	textarea {
		padding: 0.75rem;
		border: 1px solid #ddd;
		border-radius: 6px;
		font-size: 0.95rem;
		font-family: inherit;
		resize: vertical;
		width: 100%;
	}

	textarea:focus {
		outline: none;
		border-color: #0f7c80;
		box-shadow: 0 0 0 2px rgba(15, 124, 128, 0.1);
	}

	.btn {
		padding: 0.75rem 1.5rem;
		border: none;
		border-radius: 6px;
		font-size: 0.95rem;
		font-weight: 500;
		cursor: pointer;
		display: inline-flex;
		align-items: center;
		gap: 0.5rem;
		transition: all 0.2s;
	}

	.btn-primary {
		background: #0f7c80;
		color: white;
	}

	.btn-primary:hover:not(:disabled) {
		background: #0a5a5e;
		transform: translateY(-1px);
		box-shadow: 0 2px 8px rgba(15, 124, 128, 0.2);
	}

	.btn-primary:disabled {
		opacity: 0.5;
		cursor: not-allowed;
	}

	.btn-outline {
		background: white;
		color: #0f7c80;
		border: 2px solid #0f7c80;
	}

	.btn-outline:hover {
		background: #f0f8f8;
	}

	.btn-danger {
		background: #ff4444;
		color: white;
	}

	.btn-danger:hover {
		background: #cc0000;
	}

	.btn-sm {
		padding: 0.5rem 1rem;
		font-size: 0.85rem;
	}

	.table-section {
		margin-bottom: 2rem;
	}

	.table-section h3 {
		margin: 0 0 1rem 0;
		font-size: 1.1rem;
		color: #333;
	}

	.data-table {
		width: 100%;
		border-collapse: collapse;
		background: white;
		border: 1px solid #e0e0e0;
		border-radius: 6px;
		overflow: hidden;
	}

	.data-table thead {
		background: #f5f5f5;
		border-bottom: 2px solid #e0e0e0;
	}

	.data-table th {
		padding: 1rem;
		text-align: left;
		font-weight: 600;
		color: #333;
		font-size: 0.95rem;
	}

	.data-table td {
		padding: 0.75rem 1rem;
		border-bottom: 1px solid #e0e0e0;
		color: #333;
	}

	.data-table tbody tr:hover {
		background: #f9f9f9;
	}

	.data-table tfoot {
		background: #f9f9f9;
		border-top: 2px solid #e0e0e0;
	}

	.data-table tfoot td {
		padding: 1rem;
		font-weight: 600;
		color: #0f7c80;
	}

	.number {
		text-align: right;
		font-family: 'Courier New', monospace;
	}

	.text-right {
		text-align: right;
	}

	.empty-state {
		padding: 2rem;
		text-align: center;
		color: #999;
	}

	.info-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
		gap: 1.5rem;
	}

	.info-item {
		padding: 1rem;
		background: white;
		border: 1px solid #e0e0e0;
		border-radius: 6px;
	}

	.info-item strong {
		display: block;
		color: #0f7c80;
		margin-bottom: 0.5rem;
		font-size: 0.9rem;
	}

	.info-item span {
		color: #333;
		font-size: 0.95rem;
	}

	.report-preview {
		background: #f9f9f9;
		padding: 2rem;
		border-radius: 8px;
		text-align: center;
	}

	.report-preview h3 {
		margin: 0 0 1rem 0;
		font-size: 1.2rem;
		color: #333;
	}

	.info-text {
		color: #666;
		margin-bottom: 1.5rem;
	}

	.quick-summary {
		margin-top: 2rem;
		padding: 1.5rem;
		background: white;
		border: 1px solid #e0e0e0;
		border-radius: 8px;
	}

	.quick-summary h3 {
		margin: 0 0 1.5rem 0;
		font-size: 1.1rem;
		color: #333;
	}

	.summary-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
		gap: 1rem;
	}

	.summary-item {
		padding: 1rem;
		background: #f9f9f9;
		border-radius: 6px;
		text-align: center;
	}

	.summary-label {
		font-size: 0.85rem;
		color: #666;
		margin-bottom: 0.5rem;
	}

	.summary-value {
		font-size: 1.4rem;
		font-weight: bold;
		color: #0f7c80;
	}

	.footer-actions {
		display: flex;
		gap: 1rem;
		justify-content: flex-end;
		padding-top: 1.5rem;
		border-top: 1px solid #e0e0e0;
	}

	.loading {
		text-align: center;
		padding: 3rem;
		color: #666;
		font-size: 1rem;
	}

	@media (max-width: 768px) {
		.header {
			flex-direction: column;
			align-items: flex-start;
		}

		.header h1 {
			font-size: 1.4rem;
		}

		.form-grid {
			grid-template-columns: 1fr;
		}

		.overview-grid {
			grid-template-columns: 1fr;
		}

		.tabs {
			display: grid;
			grid-template-columns: repeat(2, minmax(0, 1fr));
			gap: 0.5rem;
		}

		.tab {
			padding: 0.75rem 1rem;
			font-size: 0.85rem;
		}

		.data-table {
			font-size: 0.85rem;
		}

		.data-table th,
		.data-table td {
			padding: 0.5rem;
		}

		.footer-actions {
			flex-direction: column;
		}
	}

	@media print {
		body {
			background: white;
		}

		.header,
		.tabs,
		.footer-actions,
		.header-actions,
		.btn {
			display: none;
		}

		.container {
			max-width: 100%;
			padding: 0;
		}
	}
</style>
