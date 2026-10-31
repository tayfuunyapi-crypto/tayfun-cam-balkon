<script lang="ts">
	import { data } from '#lib/stores/data';
	import { recordData, statusInfo, formatMoney } from '#lib/workflow';
	import { ChevronLeft, Download, Printer, AlertCircle } from '@lucide/svelte';

	import { page } from '$app/state';
	const params = $derived(page.params);
	let project = $state<any>(null);
	let drawing = $state<any>(null);
	let montageData = $state<any>(null);
	let generating = $state(false);

	data.subscribe(dataStore => {
		const proj = params.key ? dataStore.projects[params.key] : null;
		const draw = proj?.data?.drawing_key ? dataStore.drawings[proj.data.drawing_key] : null;
		project = proj;
		drawing = draw;
		montageData = proj?.data?.montage_details || {
			workers: [],
			materials: [],
			labor_cost: 0,
			material_cost: 0,
			notes: ''
		};
	});

	function production() {
		if (!drawing) return {};
		return drawing.data?.production || {};
	}

	function getTotalCost() {
		const materials = montageData?.materials || [];
		const workers = montageData?.workers || [];

		const materialTotal = materials.reduce((sum: number, m: any) => sum + (m.quantity * (m.unit_cost || 0)), 0);
		const laborTotal = workers.reduce((sum: number, w: any) => sum + (w.hours * (w.hourly_rate || 0)), 0);

		return {
			materials: materialTotal,
			labor: laborTotal,
			total: materialTotal + laborTotal
		};
	}

	function downloadPDF() {
		generating = true;
		const element = document.getElementById('report-content');
		if (!element) {
			generating = false;
			return;
		}

		// Create a temporary window for printing
		const printWindow = window.open('', 'PRINT', 'height=800,width=1000');
		if (!printWindow) {
			generating = false;
			alert('Popup blocker may have prevented PDF download');
			return;
		}

		const html = `
			<!DOCTYPE html>
			<html>
				<head>
					<title>Montaj Raporu - ${project?.data?.name || 'Proje'}</title>
					<style>
						* { margin: 0; padding: 0; box-sizing: border-box; }
						body { font-family: Arial, sans-serif; padding: 20px; background: white; color: #333; }
						.header { margin-bottom: 30px; border-bottom: 2px solid #0f7c80; padding-bottom: 20px; }
						.header h1 { color: #0f7c80; font-size: 28px; margin-bottom: 5px; }
						.header p { color: #666; font-size: 12px; margin-bottom: 3px; }
						.section { margin-bottom: 25px; }
						.section h2 { color: #0f7c80; font-size: 16px; margin-bottom: 12px; padding-bottom: 8px; border-bottom: 1px solid #ddd; }
						.row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 15px; }
						.row.full { grid-template-columns: 1fr; }
						.field { }
						.field label { display: block; color: #666; font-size: 11px; margin-bottom: 4px; font-weight: bold; }
						.field value { display: block; color: #333; font-size: 14px; }
						table { width: 100%; border-collapse: collapse; margin-bottom: 15px; }
						th { background: #f0f0f0; color: #0f7c80; padding: 10px; text-align: left; font-size: 12px; font-weight: bold; border-bottom: 2px solid #ddd; }
						td { padding: 8px 10px; border-bottom: 1px solid #eee; font-size: 12px; }
						tr:nth-child(even) { background: #f9f9f9; }
						.cost-summary { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; background: #f0f9f8; padding: 15px; border-radius: 6px; }
						.cost-item { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #ddd; }
						.cost-item:last-child { border-bottom: none; }
						.cost-label { color: #666; font-size: 12px; }
						.cost-value { color: #0f7c80; font-weight: bold; font-size: 13px; }
						.cost-total { grid-column: 1/-1; display: flex; justify-content: space-between; padding: 12px 0; border-top: 2px solid #0f7c80; margin-top: 8px; }
						.cost-total .cost-label { color: #0f7c80; font-weight: bold; }
						.cost-total .cost-value { font-size: 18px; }
						.chart { display: flex; align-items: center; justify-content: center; height: 200px; background: #fff; margin: 15px 0; }
						.notes { background: #fff8f0; padding: 12px; border-radius: 6px; border-left: 3px solid #ff9900; font-size: 12px; line-height: 1.6; }
						.footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 10px; color: #999; text-align: center; }
						@media print {
							body { padding: 0; }
							.header { break-after: avoid; }
							.section { break-inside: avoid; }
							table { break-inside: avoid; }
						}
					</style>
				</head>
				<body>
					<div class="header">
						<h1>📋 Montaj Raporu</h1>
						<p><strong>Proje:</strong> ${project?.data?.name || 'N/A'}</p>
						<p><strong>Müşteri:</strong> ${project?.data?.customer || 'N/A'}</p>
						<p><strong>Tarih:</strong> ${new Date().toLocaleDateString('tr-TR')}</p>
					</div>

					<div class="section">
						<h2>İş Detayları</h2>
						<div class="row">
							<div class="field">
								<label>Sistem</label>
								<value>${production().system || '-'}</value>
							</div>
							<div class="field">
								<label>Renk</label>
								<value>${production().color || '-'}</value>
							</div>
						</div>
						<div class="row full">
							<div class="field">
								<label>Adres</label>
								<value>${project?.data?.address || '-'}</value>
							</div>
						</div>
						<div class="row full">
							<div class="field">
								<label>Notlar</label>
								<value>${montageData?.notes || '-'}</value>
							</div>
						</div>
					</div>

					<div class="section">
						<h2>Malzeme Listesi</h2>
						<table>
							<thead>
								<tr>
									<th>Malzeme</th>
									<th>Miktar</th>
									<th>Birim</th>
									<th style="text-align: right;">Birim Fiyat</th>
									<th style="text-align: right;">Toplam</th>
								</tr>
							</thead>
							<tbody>
								${montageData?.materials && montageData.materials.length > 0
									? montageData.materials.map((m: any) => `
										<tr>
											<td>${m.name || '-'}</td>
											<td>${m.quantity || 0}</td>
											<td>${m.unit || '-'}</td>
											<td style="text-align: right;">₺${(m.unit_cost || 0).toLocaleString('tr-TR')}</td>
											<td style="text-align: right;">₺${((m.quantity || 0) * (m.unit_cost || 0)).toLocaleString('tr-TR')}</td>
										</tr>
									`).join('')
									: '<tr><td colspan="5" style="text-align: center; color: #999;">Malzeme kaydı bulunmamaktadır</td></tr>'
								}
							</tbody>
						</table>
					</div>

					<div class="section">
						<h2>İşçi Listesi</h2>
						<table>
							<thead>
								<tr>
									<th>Ad</th>
									<th>Rol</th>
									<th>Saat</th>
									<th style="text-align: right;">Saatlik Ücret</th>
									<th style="text-align: right;">Toplam</th>
								</tr>
							</thead>
							<tbody>
								${montageData?.workers && montageData.workers.length > 0
									? montageData.workers.map((w: any) => `
										<tr>
											<td>${w.name || '-'}</td>
											<td>${w.role || '-'}</td>
											<td>${w.hours || 0}</td>
											<td style="text-align: right;">₺${(w.hourly_rate || 0).toLocaleString('tr-TR')}</td>
											<td style="text-align: right;">₺${((w.hours || 0) * (w.hourly_rate || 0)).toLocaleString('tr-TR')}</td>
										</tr>
									`).join('')
									: '<tr><td colspan="5" style="text-align: center; color: #999;">İşçi kaydı bulunmamaktadır</td></tr>'
								}
							</tbody>
						</table>
					</div>

					<div class="section">
						<h2>Maliyet Özeti</h2>
						<div class="cost-summary">
							<div style="grid-column: 1/-1;">
								<div class="cost-item">
									<span class="cost-label">Malzeme Toplam</span>
									<span class="cost-value">₺${getTotalCost().materials.toLocaleString('tr-TR')}</span>
								</div>
								<div class="cost-item">
									<span class="cost-label">İşçilik Toplam</span>
									<span class="cost-value">₺${getTotalCost().labor.toLocaleString('tr-TR')}</span>
								</div>
								<div class="cost-total">
									<span class="cost-label">GENEL TOPLAM</span>
									<span class="cost-value">₺${getTotalCost().total.toLocaleString('tr-TR')}</span>
								</div>
							</div>
						</div>
					</div>

					<div class="footer">
						<p>Bu rapor otomatik olarak oluşturulmuştur. ${new Date().toLocaleString('tr-TR')}</p>
					</div>
				</body>
			</html>
		`;

		printWindow.document.write(html);
		printWindow.document.close();

		setTimeout(() => {
			printWindow.print();
			printWindow.close();
			generating = false;
		}, 250);
	}

	function handlePrint() {
		window.print();
	}

	const costs = getTotalCost();
</script>

<svelte:head>
	<title>Montaj Raporu | Tayfun Yapı</title>
</svelte:head>

<div class="page">
	<header>
		<a href="/montage/{params.key}" class="back">
			<ChevronLeft size={20} />
			<span>Geri</span>
		</a>
		<div>
			<span>OPERASYON</span>
			<h1>Montaj Raporu</h1>
		</div>
		<div class="actions">
			<button onclick={downloadPDF} disabled={generating} class="btn-export">
				<Download size={18} />
				<span>{generating ? 'Oluşturuluyor...' : 'PDF İndir'}</span>
			</button>
			<button onclick={handlePrint} class="btn-print">
				<Printer size={18} />
				<span>Yazdır</span>
			</button>
		</div>
	</header>

	{#if project && montageData}
		<div id="report-content" class="report">
			<div class="header-section">
				<div class="title-block">
					<h2>Montaj Raporu</h2>
					<p class="subtitle">{new Date().toLocaleDateString('tr-TR')}</p>
				</div>
			</div>

			<section class="content-section">
				<h3>İş Bilgileri</h3>
				<div class="info-grid">
					<div class="info-item">
						<span class="label">Proje</span>
						<span class="value">{project?.data?.name || 'N/A'}</span>
					</div>
					<div class="info-item">
						<span class="label">Müşteri</span>
						<span class="value">{project?.data?.customer || 'N/A'}</span>
					</div>
					<div class="info-item">
						<span class="label">Sistem</span>
						<span class="value">{production().system || '-'}</span>
					</div>
					<div class="info-item">
						<span class="label">Renk</span>
						<span class="value">{production().color || '-'}</span>
					</div>
					<div class="info-item" style="grid-column: 1/-1;">
						<span class="label">Adres</span>
						<span class="value">{project?.data?.address || '-'}</span>
					</div>
				</div>
			</section>

			<section class="content-section">
				<h3>Malzeme Listesi</h3>
				<div class="table-wrapper">
					<table>
						<thead>
							<tr>
								<th>Malzeme</th>
								<th>Miktar</th>
								<th>Birim</th>
								<th class="align-right">Birim Fiyat</th>
								<th class="align-right">Toplam</th>
							</tr>
						</thead>
						<tbody>
							{#if montageData?.materials && montageData.materials.length > 0}
								{#each montageData.materials as material}
									<tr>
										<td>{material.name || '-'}</td>
										<td>{material.quantity || 0}</td>
										<td>{material.unit || '-'}</td>
										<td class="align-right">₺{(material.unit_cost || 0).toLocaleString('tr-TR')}</td>
										<td class="align-right">₺{((material.quantity || 0) * (material.unit_cost || 0)).toLocaleString('tr-TR')}</td>
									</tr>
								{/each}
							{:else}
								<tr>
									<td colspan="5" class="empty">Malzeme kaydı bulunmamaktadır</td>
								</tr>
							{/if}
						</tbody>
					</table>
				</div>
			</section>

			<section class="content-section">
				<h3>İşçi Listesi</h3>
				<div class="table-wrapper">
					<table>
						<thead>
							<tr>
								<th>Ad</th>
								<th>Rol</th>
								<th>Saat</th>
								<th class="align-right">Saatlik Ücret</th>
								<th class="align-right">Toplam</th>
							</tr>
						</thead>
						<tbody>
							{#if montageData?.workers && montageData.workers.length > 0}
								{#each montageData.workers as worker}
									<tr>
										<td>{worker.name || '-'}</td>
										<td>{worker.role || '-'}</td>
										<td>{worker.hours || 0}</td>
										<td class="align-right">₺{(worker.hourly_rate || 0).toLocaleString('tr-TR')}</td>
										<td class="align-right">₺{((worker.hours || 0) * (worker.hourly_rate || 0)).toLocaleString('tr-TR')}</td>
									</tr>
								{/each}
							{:else}
								<tr>
									<td colspan="5" class="empty">İşçi kaydı bulunmamaktadır</td>
								</tr>
							{/if}
						</tbody>
					</table>
				</div>
			</section>

			<section class="content-section">
				<h3>Maliyet Özeti</h3>
				<div class="cost-summary">
					<div class="cost-row">
						<span class="cost-label">Malzeme Toplam</span>
						<span class="cost-value">₺{costs.materials.toLocaleString('tr-TR')}</span>
					</div>
					<div class="cost-row">
						<span class="cost-label">İşçilik Toplam</span>
						<span class="cost-value">₺{costs.labor.toLocaleString('tr-TR')}</span>
					</div>
					<div class="cost-row total">
						<span class="cost-label">GENEL TOPLAM</span>
						<span class="cost-value">₺{costs.total.toLocaleString('tr-TR')}</span>
					</div>
				</div>
			</section>

			{#if montageData?.notes}
				<section class="content-section">
					<h3>Notlar</h3>
					<div class="notes-box">
						{montageData.notes}
					</div>
				</section>
			{/if}
		</div>
	{:else}
		<div class="loading">
			<AlertCircle size={32} />
			<p>Montaj verisi yükleniyor...</p>
		</div>
	{/if}
</div>

<style>
	.page {
		max-width: 1200px;
		margin: auto;
		padding: 30px;
	}

	header {
		display: flex;
		align-items: center;
		gap: 20px;
		margin-bottom: 30px;
		padding-bottom: 20px;
		border-bottom: 2px solid #dfe4e8;
	}

	.back {
		display: flex;
		align-items: center;
		gap: 8px;
		padding: 8px 12px;
		background: #f0f2f5;
		border-radius: 6px;
		color: #0f7c80;
		text-decoration: none;
		font-weight: 600;
		font-size: 13px;
		cursor: pointer;
		transition: all 0.2s;
	}

	.back:hover {
		background: #e0e5ea;
	}

	header > div:nth-child(2) {
		flex: 1;
	}

	header span {
		display: block;
		font-size: 10px;
		font-weight: 800;
		color: #0f7c80;
		letter-spacing: 1px;
		margin-bottom: 2px;
	}

	header h1 {
		font-size: 28px;
		margin: 0;
		color: #1a1a1a;
	}

	.actions {
		display: flex;
		gap: 12px;
	}

	.btn-export,
	.btn-print {
		display: flex;
		align-items: center;
		gap: 8px;
		padding: 10px 16px;
		background: #0f7c80;
		color: white;
		border: none;
		border-radius: 6px;
		font-weight: 600;
		font-size: 13px;
		cursor: pointer;
		transition: all 0.2s;
	}

	.btn-export:hover:not(:disabled),
	.btn-print:hover {
		background: #0a5a5d;
		transform: translateY(-2px);
		box-shadow: 0 4px 12px rgba(15, 124, 128, 0.3);
	}

	.btn-export:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	.btn-print {
		background: #f59e0b;
	}

	.btn-print:hover {
		background: #d97706;
	}

	.report {
		background: white;
		border: 1px solid #dfe4e8;
		border-radius: 8px;
		padding: 40px;
	}

	.header-section {
		margin-bottom: 30px;
		padding-bottom: 20px;
		border-bottom: 2px solid #0f7c80;
	}

	.title-block h2 {
		font-size: 24px;
		color: #0f7c80;
		margin: 0;
		margin-bottom: 4px;
	}

	.subtitle {
		font-size: 12px;
		color: #666;
		margin: 0;
	}

	.content-section {
		margin-bottom: 30px;
	}

	.content-section h3 {
		font-size: 16px;
		color: #0f7c80;
		margin: 0 0 15px 0;
		padding-bottom: 10px;
		border-bottom: 1px solid #dfe4e8;
	}

	.info-grid {
		display: grid;
		grid-template-columns: repeat(2, 1fr);
		gap: 15px;
	}

	.info-item {
		display: flex;
		flex-direction: column;
		gap: 6px;
	}

	.label {
		font-size: 11px;
		color: #666;
		font-weight: bold;
		text-transform: uppercase;
	}

	.value {
		font-size: 14px;
		color: #1a1a1a;
	}

	.table-wrapper {
		overflow-x: auto;
	}

	table {
		width: 100%;
		border-collapse: collapse;
		margin-bottom: 15px;
	}

	thead {
		background: #f0f2f5;
	}

	th {
		padding: 12px;
		text-align: left;
		font-size: 12px;
		font-weight: 700;
		color: #0f7c80;
		border-bottom: 2px solid #dfe4e8;
	}

	th.align-right {
		text-align: right;
	}

	td {
		padding: 10px 12px;
		font-size: 13px;
		border-bottom: 1px solid #edf0f2;
		color: #374151;
	}

	td.empty {
		text-align: center;
		color: #999;
		font-style: italic;
		padding: 20px;
	}

	td.align-right {
		text-align: right;
		font-variant-numeric: tabular-nums;
	}

	tbody tr:hover {
		background: #f9fafb;
	}

	.cost-summary {
		background: #f0f9f8;
		border-left: 4px solid #0f7c80;
		padding: 20px;
		border-radius: 6px;
	}

	.cost-row {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 10px 0;
		border-bottom: 1px solid rgba(15, 124, 128, 0.1);
	}

	.cost-row.total {
		border-bottom: none;
		border-top: 2px solid #0f7c80;
		margin-top: 8px;
		padding-top: 12px;
		padding-bottom: 0;
	}

	.cost-label {
		font-size: 13px;
		color: #374151;
	}

	.cost-row.total .cost-label {
		color: #0f7c80;
		font-weight: 700;
	}

	.cost-value {
		font-size: 15px;
		font-weight: 700;
		color: #0f7c80;
		font-variant-numeric: tabular-nums;
	}

	.cost-row.total .cost-value {
		font-size: 20px;
	}

	.notes-box {
		background: #fff8f0;
		border-left: 3px solid #f59e0b;
		padding: 15px;
		border-radius: 4px;
		font-size: 13px;
		line-height: 1.6;
		color: #333;
		white-space: pre-wrap;
		word-wrap: break-word;
	}

	.loading {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 15px;
		padding: 60px 20px;
		color: #666;
	}

	@media print {
		.page {
			padding: 0;
		}

		header {
			display: none;
		}

		.report {
			border: none;
			padding: 0;
			box-shadow: none;
		}

		.content-section {
			page-break-inside: avoid;
			margin-bottom: 20px;
		}

		table {
			page-break-inside: avoid;
		}

		@page {
			margin: 20mm;
		}
	}

	@media (max-width: 768px) {
		.page {
			padding: 20px 15px;
		}

		header {
			flex-wrap: wrap;
			gap: 15px;
		}

		.actions {
			width: 100%;
		}

		.btn-export,
		.btn-print {
			flex: 1;
			justify-content: center;
		}

		.report {
			padding: 20px;
		}

		.info-grid {
			grid-template-columns: 1fr;
		}

		table {
			font-size: 12px;
		}

		td,
		th {
			padding: 8px;
		}
	}
</style>
