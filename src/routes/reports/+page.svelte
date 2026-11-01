<script lang="ts">
	import { onMount } from 'svelte';
	import { customerStore } from '#lib/stores/customerStore';
	import { projectStore } from '#lib/stores/projectStore';
	import { quoteStore } from '#lib/stores/quoteStore';
	import Card from '#lib/components/Card.svelte';
	import Button from '#lib/components/Button.svelte';
	import PageContainer from '#lib/components/Layout/PageContainer.svelte';
	import { Download, TrendingUp, Users, FileText, CheckCircle } from 'lucide-svelte';

	let isLoading = $state(true);

	onMount(async () => {
		await Promise.all([
			customerStore.loadAll(),
			projectStore.loadAll(),
			quoteStore.loadAll()
		]);
		isLoading = false;
	});

	// Müşteri istatistikleri
	let totalCustomers = $derived($customerStore.items.length);

	// Proje istatistikleri
	let totalProjects = $derived($projectStore.items.length);
	let completedProjects = $derived(
		$projectStore.items.filter((p) => p.status === 'completed').length
	);
	let activeProjects = $derived(
		$projectStore.items.filter((p) => p.status === 'in_progress').length
	);
	let totalProjectBudget = $derived(
		$projectStore.items.reduce((sum, p) => sum + (p.budget || 0), 0)
	);

	// Teklif istatistikleri
	let totalQuotes = $derived($quoteStore.items.length);
	let acceptedQuotes = $derived(
		$quoteStore.items.filter((q) => q.status === 'accepted').length
	);
	let totalQuoteValue = $derived(
		$quoteStore.items.reduce((sum, q) => sum + (q.total || 0), 0)
	);
	let acceptedQuoteValue = $derived(
		$quoteStore.items
			.filter((q) => q.status === 'accepted')
			.reduce((sum, q) => sum + (q.total || 0), 0)
	);
	let conversionRate = $derived(totalQuotes > 0 ? ((acceptedQuotes / totalQuotes) * 100).toFixed(1) : '0');

	function formatCurrency(value: number) {
		return new Intl.NumberFormat('tr-TR', {
			style: 'currency',
			currency: 'TRY'
		}).format(value);
	}

	async function exportMonthlyReport() {
		try {
			const report = {
				title: 'Aylık Rapor',
				date: new Date().toLocaleDateString('tr-TR'),
				stats: {
					totalCustomers,
					totalProjects,
					completedProjects,
					activeProjects,
					totalProjectBudget,
					totalQuotes,
					acceptedQuotes,
					totalQuoteValue,
					acceptedQuoteValue,
					conversionRate: `${conversionRate}%`
				}
			};

			const htmlContent = `
				<!DOCTYPE html>
				<html lang="tr">
				<head>
					<meta charset="UTF-8">
					<title>Aylık Rapor</title>
					<style>
						* { margin: 0; padding: 0; box-sizing: border-box; }
						body {
							font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
							line-height: 1.6;
							color: #26323b;
							background: white;
							padding: 20mm;
						}
						.page {
							max-width: 210mm;
							margin: auto;
						}
						.header {
							border-bottom: 3px solid #0f7c80;
							padding-bottom: 20px;
							margin-bottom: 30px;
						}
						h1 {
							color: #0f7c80;
							font-size: 28px;
							margin-bottom: 10px;
						}
						.date {
							color: #7c8791;
							font-size: 14px;
						}
						.section {
							margin-bottom: 30px;
						}
						.section-title {
							font-size: 16px;
							font-weight: 700;
							color: #0f7c80;
							text-transform: uppercase;
							margin-bottom: 15px;
							letter-spacing: 1px;
						}
						.stats-grid {
							display: grid;
							grid-template-columns: 1fr 1fr;
							gap: 15px;
							margin-bottom: 20px;
						}
						.stat-card {
							background: #f5f7f9;
							padding: 15px;
							border-radius: 6px;
							border-left: 4px solid #0f7c80;
						}
						.stat-label {
							font-size: 12px;
							color: #7c8791;
							text-transform: uppercase;
							margin-bottom: 5px;
						}
						.stat-value {
							font-size: 20px;
							font-weight: 700;
							color: #26323b;
						}
						.footer {
							margin-top: 40px;
							padding-top: 20px;
							border-top: 1px solid #e9ecef;
							font-size: 12px;
							color: #7c8791;
							text-align: center;
						}
					</style>
				</head>
				<body>
					<div class="page">
						<div class="header">
							<h1>Tayfun Yapı - Aylık Rapor</h1>
							<p class="date">Oluşturma Tarihi: ${report.date}</p>
						</div>

						<div class="section">
							<div class="section-title">Müşteri İstatistikleri</div>
							<div class="stats-grid">
								<div class="stat-card">
									<div class="stat-label">Toplam Müşteri</div>
									<div class="stat-value">${report.stats.totalCustomers}</div>
								</div>
							</div>
						</div>

						<div class="section">
							<div class="section-title">Proje İstatistikleri</div>
							<div class="stats-grid">
								<div class="stat-card">
									<div class="stat-label">Toplam Proje</div>
									<div class="stat-value">${report.stats.totalProjects}</div>
								</div>
								<div class="stat-card">
									<div class="stat-label">Tamamlanan Proje</div>
									<div class="stat-value">${report.stats.completedProjects}</div>
								</div>
								<div class="stat-card">
									<div class="stat-label">Devam Eden Proje</div>
									<div class="stat-value">${report.stats.activeProjects}</div>
								</div>
								<div class="stat-card">
									<div class="stat-label">Toplam Bütçe</div>
									<div class="stat-value">${formatCurrency(report.stats.totalProjectBudget)}</div>
								</div>
							</div>
						</div>

						<div class="section">
							<div class="section-title">Teklif İstatistikleri</div>
							<div class="stats-grid">
								<div class="stat-card">
									<div class="stat-label">Toplam Teklif</div>
									<div class="stat-value">${report.stats.totalQuotes}</div>
								</div>
								<div class="stat-card">
									<div class="stat-label">Kabul Edilen</div>
									<div class="stat-value">${report.stats.acceptedQuotes}</div>
								</div>
								<div class="stat-card">
									<div class="stat-label">Dönüşüm Oranı</div>
									<div class="stat-value">${report.stats.conversionRate}</div>
								</div>
								<div class="stat-card">
									<div class="stat-label">Toplam Teklif Değeri</div>
									<div class="stat-value">${formatCurrency(report.stats.totalQuoteValue)}</div>
								</div>
								<div class="stat-card">
									<div class="stat-label">Kabul Edilen Teklifler</div>
									<div class="stat-value">${formatCurrency(report.stats.acceptedQuoteValue)}</div>
								</div>
							</div>
						</div>

						<div class="footer">
							<p>Tayfun Yapı Cam Balkon Sistemleri | Edremit, Balıkesir</p>
							<p>Bu belge bilgisayar tarafından üretilmiştir ve imza gerektirmez.</p>
						</div>
					</div>
				</body>
				</html>
			`;

			const blob = new Blob([htmlContent], { type: 'text/html;charset=utf-8' });
			const link = document.createElement('a');
			const url = URL.createObjectURL(blob);

			link.setAttribute('href', url);
			link.setAttribute('download', `Aylik-Rapor-${new Date().toISOString().split('T')[0]}.html`);
			link.style.visibility = 'hidden';

			document.body.appendChild(link);
			link.click();
			document.body.removeChild(link);
			URL.revokeObjectURL(url);
		} catch (error) {
			console.error('Export failed:', error);
		}
	}
</script>

<PageContainer title="Raporlar ve Analitics">
	{#if isLoading}
		<div class="loading">Yükleniyor...</div>
	{:else}
		<!-- Müşteri İstatistikleri -->
		<div class="section">
			<h2 class="section-title">Müşteri İstatistikleri</h2>
			<div class="stats-grid">
				<Card variant="primary">
					<div class="stat-icon">
						<Users size={32} />
					</div>
					<div class="stat-content">
						<div class="stat-label">Toplam Müşteri</div>
						<div class="stat-value">{totalCustomers}</div>
					</div>
				</Card>
			</div>
		</div>

		<!-- Proje İstatistikleri -->
		<div class="section">
			<h2 class="section-title">Proje İstatistikleri</h2>
			<div class="stats-grid">
				<Card variant="primary">
					<div class="stat-icon">
						<FileText size={32} />
					</div>
					<div class="stat-content">
						<div class="stat-label">Toplam Proje</div>
						<div class="stat-value">{totalProjects}</div>
					</div>
				</Card>

				<Card variant="success">
					<div class="stat-icon">
						<CheckCircle size={32} />
					</div>
					<div class="stat-content">
						<div class="stat-label">Tamamlanan</div>
						<div class="stat-value">{completedProjects}</div>
						<div class="stat-percentage">{totalProjects > 0 ? ((completedProjects / totalProjects) * 100).toFixed(0) : 0}%</div>
					</div>
				</Card>

				<Card variant="primary">
					<div class="stat-icon">
						<TrendingUp size={32} />
					</div>
					<div class="stat-content">
						<div class="stat-label">Devam Eden</div>
						<div class="stat-value">{activeProjects}</div>
					</div>
				</Card>

				<Card variant="primary">
					<div class="stat-icon">
						<span class="budget-icon">₺</span>
					</div>
					<div class="stat-content">
						<div class="stat-label">Toplam Bütçe</div>
						<div class="stat-value">{formatCurrency(totalProjectBudget)}</div>
					</div>
				</Card>
			</div>
		</div>

		<!-- Teklif İstatistikleri -->
		<div class="section">
			<h2 class="section-title">Teklif İstatistikleri</h2>
			<div class="stats-grid">
				<Card variant="primary">
					<div class="stat-icon">
						<FileText size={32} />
					</div>
					<div class="stat-content">
						<div class="stat-label">Toplam Teklif</div>
						<div class="stat-value">{totalQuotes}</div>
					</div>
				</Card>

				<Card variant="success">
					<div class="stat-icon">
						<CheckCircle size={32} />
					</div>
					<div class="stat-content">
						<div class="stat-label">Kabul Edilen</div>
						<div class="stat-value">{acceptedQuotes}</div>
						<div class="stat-percentage">{conversionRate}%</div>
					</div>
				</Card>

				<Card variant="primary">
					<div class="stat-icon">
						<span class="budget-icon">₺</span>
					</div>
					<div class="stat-content">
						<div class="stat-label">Toplam Teklif Değeri</div>
						<div class="stat-value">{formatCurrency(totalQuoteValue)}</div>
					</div>
				</Card>

				<Card variant="success">
					<div class="stat-icon">
						<span class="budget-icon">₺</span>
					</div>
					<div class="stat-content">
						<div class="stat-label">Kabul Edilen Değer</div>
						<div class="stat-value">{formatCurrency(acceptedQuoteValue)}</div>
					</div>
				</Card>
			</div>
		</div>

		<!-- Özet İstatistikler -->
		<div class="section summary">
			<h2 class="section-title">Özet</h2>
			<div class="summary-grid">
				<div class="summary-item">
					<span class="summary-label">Müşteri Başına Ort. Proje:</span>
					<span class="summary-value">{totalCustomers > 0 ? (totalProjects / totalCustomers).toFixed(1) : 0}</span>
				</div>
				<div class="summary-item">
					<span class="summary-label">Müşteri Başına Ort. Teklif:</span>
					<span class="summary-value">{totalCustomers > 0 ? (totalQuotes / totalCustomers).toFixed(1) : 0}</span>
				</div>
				<div class="summary-item">
					<span class="summary-label">Ortalama Proje Bütçesi:</span>
					<span class="summary-value">{formatCurrency(totalProjects > 0 ? totalProjectBudget / totalProjects : 0)}</span>
				</div>
				<div class="summary-item">
					<span class="summary-label">Ortalama Teklif Değeri:</span>
					<span class="summary-value">{formatCurrency(totalQuotes > 0 ? totalQuoteValue / totalQuotes : 0)}</span>
				</div>
			</div>
		</div>

		<!-- Export Button -->
		<div class="export-section">
			<Button variant="secondary" on:click={exportMonthlyReport}>
				<Download size={18} />
				Aylık Raporu İndir (PDF/HTML)
			</Button>
		</div>
	{/if}
</PageContainer>

<style>
	.section {
		margin-bottom: var(--spacing-8);
	}

	.section-title {
		font-size: var(--text-lg);
		font-weight: 700;
		color: var(--color-primary);
		text-transform: uppercase;
		margin-bottom: var(--spacing-4);
		letter-spacing: 0.5px;
	}

	.stats-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
		gap: var(--spacing-4);
		margin-bottom: var(--spacing-6);
	}

	:global(.stats-grid .card) {
		display: flex;
		align-items: center;
		gap: var(--spacing-4);
		padding: var(--spacing-4);
	}

	.stat-icon {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 60px;
		height: 60px;
		background: var(--color-primary-light);
		border-radius: var(--radius-md);
		color: var(--color-primary);
		flex-shrink: 0;
	}

	.budget-icon {
		font-size: 28px;
		font-weight: 700;
	}

	.stat-content {
		flex: 1;
	}

	.stat-label {
		font-size: var(--text-sm);
		color: var(--color-text-secondary);
		text-transform: uppercase;
		margin-bottom: var(--spacing-1);
	}

	.stat-value {
		font-size: var(--text-2xl);
		font-weight: 700;
		color: var(--color-text-primary);
	}

	.stat-percentage {
		font-size: var(--text-sm);
		color: var(--color-primary);
		margin-top: var(--spacing-1);
	}

	.summary {
		background: var(--color-bg-secondary);
		padding: var(--spacing-6);
		border-radius: var(--radius-lg);
		border: 1px solid var(--color-border);
	}

	.summary-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
		gap: var(--spacing-4);
	}

	.summary-item {
		display: flex;
		flex-direction: column;
		gap: var(--spacing-2);
		padding: var(--spacing-3);
		background: var(--color-bg-primary);
		border-radius: var(--radius-md);
		border-left: 3px solid var(--color-primary);
	}

	.summary-label {
		font-size: var(--text-sm);
		color: var(--color-text-secondary);
		font-weight: 600;
	}

	.summary-value {
		font-size: var(--text-lg);
		font-weight: 700;
		color: var(--color-primary);
	}

	.export-section {
		display: flex;
		justify-content: center;
		padding: var(--spacing-6);
		margin-top: var(--spacing-6);
	}

	.loading {
		text-align: center;
		padding: var(--spacing-12);
		color: var(--color-text-secondary);
	}

	@media (max-width: 768px) {
		.stats-grid {
			grid-template-columns: 1fr;
		}

		.summary-grid {
			grid-template-columns: 1fr;
		}
	}
</style>
