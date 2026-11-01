<script lang="ts">
	import Viewer3D from '#lib/components/Viewer3D.svelte';
	import PageContainer from '#lib/components/Layout/PageContainer.svelte';
	import Card from '#lib/components/Card.svelte';

	const products = [
		{
			id: 1,
			name: 'Düz Sürme Sistemi',
			description: 'Modern tasarım ile enerji verimli cam balkon sistemleri',
			modelType: 'cube' as const,
			color: '#0f7c80',
			details: [
				'Yüksek kaliteli alüminyum çerçeve',
				'Isı yalıtımlı cam yapısı',
				'Uzun ömürlü ve dayanıklı',
				'Kolay kullanım mekanizması'
			]
		},
		{
			id: 2,
			name: 'Katlanır Sistem',
			description: 'Kompakt ve pratik cam balkon çözümü',
			modelType: 'pyramid' as const,
			color: '#10b981',
			details: [
				'Katlanabilir tasarım',
				'Küçük alanlara uygun',
				'Hava geçirgen yapı',
				'Estetik görünüm'
			]
		},
		{
			id: 3,
			name: 'Döner Sistemi',
			description: 'Premium kaliteli dönüştürülebilir cam balkon',
			modelType: 'sphere' as const,
			color: '#f59e0b',
			details: [
				'Yüksek kalite malzeme',
				'Döner mekanizması',
				'Tam hava kontrolü',
				'Profesyonel kurulum'
			]
		},
		{
			id: 4,
			name: 'Giyotin Sistemi',
			description: 'Standart ve güvenilir cam balkon sistemi',
			modelType: 'cube' as const,
			color: '#3b82f6',
			details: [
				'Kolay kontrol mekanizması',
				'Güvenlik kilidi',
				'Güç tasarrufu',
				'Uzun kullanım ömrü'
			]
		},
		{
			id: 5,
			name: 'Isıcam Sistemi',
			description: 'Işık ve ısı yönetimi için gelişmiş sistem',
			modelType: 'pyramid' as const,
			color: '#ef4444',
			details: [
				'Güneş ışığı kontrolü',
				'Enerji tasarrufu',
				'Ses yalıtımı',
				'Tamamen özelleştirilebilir'
			]
		},
		{
			id: 6,
			name: 'Kürüşme Sistemi',
			description: 'Sabit cam balkon sistemleri',
			modelType: 'sphere' as const,
			color: '#8b5cf6',
			details: [
				'Sabit yapı',
				'Maksimum görüş alanı',
				'Dayanıklı tasarım',
				'Düşük bakım maliyeti'
			]
		}
	];
</script>

<PageContainer title="Ürünler - 3D Görüntüleyici">
	<div class="intro">
		<p class="intro-text">
			Tayfun Yapı'nın cam balkon sistemlerini etkileşimli 3D ortamda görüntüleyin. Her ürünü
			döndürerek detaylarını inceleyebilirsiniz.
		</p>
	</div>

	<div class="products-grid">
		{#each products as product (product.id)}
			<div class="product-card">
				<Viewer3D
					title={product.name}
					description={product.description}
					modelType={product.modelType}
					color={product.color}
					size={2}
					autoRotate={true}
				/>

				<div class="product-details">
					<h3>{product.name}</h3>
					<p class="product-description">{product.description}</p>

					<div class="features-list">
						<h4>Özellikler:</h4>
						<ul>
							{#each product.details as detail}
								<li>{detail}</li>
							{/each}
						</ul>
					</div>
				</div>
			</div>
		{/each}
	</div>

	<div class="comparison-section">
		<h2>Sistem Karşılaştırması</h2>

		<div class="comparison-table">
			<table>
				<thead>
					<tr>
						<th>Sistem Adı</th>
						<th>Yapı</th>
						<th>Hava Kontrolü</th>
						<th>Estetik</th>
						<th>Dayanıklılık</th>
						<th>Enerji Verimliliği</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td class="system-name">Düz Sürme</td>
						<td>⭐⭐⭐⭐</td>
						<td>⭐⭐⭐</td>
						<td>⭐⭐⭐⭐</td>
						<td>⭐⭐⭐⭐⭐</td>
						<td>⭐⭐⭐⭐</td>
					</tr>
					<tr>
						<td class="system-name">Katlanır</td>
						<td>⭐⭐⭐</td>
						<td>⭐⭐⭐⭐</td>
						<td>⭐⭐⭐⭐</td>
						<td>⭐⭐⭐</td>
						<td>⭐⭐⭐</td>
					</tr>
					<tr>
						<td class="system-name">Döner</td>
						<td>⭐⭐⭐⭐⭐</td>
						<td>⭐⭐⭐⭐⭐</td>
						<td>⭐⭐⭐⭐⭐</td>
						<td>⭐⭐⭐⭐</td>
						<td>⭐⭐⭐⭐</td>
					</tr>
					<tr>
						<td class="system-name">Giyotin</td>
						<td>⭐⭐⭐⭐</td>
						<td>⭐⭐⭐</td>
						<td>⭐⭐⭐</td>
						<td>⭐⭐⭐⭐⭐</td>
						<td>⭐⭐⭐</td>
					</tr>
					<tr>
						<td class="system-name">Isıcam</td>
						<td>⭐⭐⭐⭐</td>
						<td>⭐⭐⭐⭐</td>
						<td>⭐⭐⭐⭐⭐</td>
						<td>⭐⭐⭐⭐</td>
						<td>⭐⭐⭐⭐⭐</td>
					</tr>
					<tr>
						<td class="system-name">Kürüşme</td>
						<td>⭐⭐⭐⭐⭐</td>
						<td>⭐⭐</td>
						<td>⭐⭐⭐⭐⭐</td>
						<td>⭐⭐⭐⭐⭐</td>
						<td>⭐⭐⭐⭐</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>

	<div class="features-info">
		<h2>Neden Tayfun Yapı?</h2>

		<div class="benefits-grid">
			<Card variant="primary">
				<div class="benefit-icon">🏆</div>
				<div class="benefit-content">
					<h3>Yüksek Kalite</h3>
					<p>15+ yıl tecrübe ve en iyi malzemeler kullanarak üretilen ürünler</p>
				</div>
			</Card>

			<Card variant="primary">
				<div class="benefit-icon">💰</div>
				<div class="benefit-content">
					<h3>Uygun Fiyat</h3>
					<p>Kaliteden ödün vermeden en rekabetçi fiyatlarla hizmet</p>
				</div>
			</Card>

			<Card variant="primary">
				<div class="benefit-icon">🔧</div>
				<div class="benefit-content">
					<h3>Profesyonel Kurulum</h3>
					<p>Uzman teknisyenler tarafından hızlı ve güvenli kurulum</p>
				</div>
			</Card>

			<Card variant="primary">
				<div class="benefit-icon">🛡️</div>
				<div class="benefit-content">
					<h3>Garantili Hizmet</h3>
					<p>2 yıl ürün garantisi ve 24/7 müşteri desteği</p>
				</div>
			</Card>

			<Card variant="primary">
				<div class="benefit-icon">📱</div>
				<div class="benefit-content">
					<h3>Kolay İletişim</h3>
					<p>Whatsapp, telefon ve e-posta ile anında iletişim</p>
				</div>
			</Card>

			<Card variant="primary">
				<div class="benefit-icon">🌟</div>
				<div class="benefit-content">
					<h3>Mühendislik Desteği</h3>
					<p>Projelendirilmiş tasarım ve uygun malzeme seçimi</p>
				</div>
			</Card>
		</div>
	</div>
</PageContainer>

<style>
	.intro {
		background: var(--color-primary-light);
		padding: var(--spacing-6);
		border-radius: var(--radius-lg);
		margin-bottom: var(--spacing-8);
		border-left: 4px solid var(--color-primary);
	}

	.intro-text {
		margin: 0;
		font-size: var(--text-base);
		color: var(--color-text-primary);
		font-weight: 500;
	}

	.products-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
		gap: var(--spacing-6);
		margin-bottom: var(--spacing-8);
	}

	.product-card {
		display: flex;
		flex-direction: column;
		gap: var(--spacing-4);
	}

	.product-card :global(.viewer-container) {
		flex: 1;
		min-height: 400px;
	}

	.product-details {
		padding: var(--spacing-4);
		background: var(--color-bg-secondary);
		border-radius: var(--radius-md);
		border: 1px solid var(--color-border);
	}

	.product-details h3 {
		margin: 0 0 var(--spacing-2) 0;
		font-size: var(--text-lg);
		color: var(--color-primary);
	}

	.product-description {
		margin: 0 0 var(--spacing-3) 0;
		font-size: var(--text-sm);
		color: var(--color-text-secondary);
	}

	.features-list {
		margin: 0;
	}

	.features-list h4 {
		margin: 0 0 var(--spacing-2) 0;
		font-size: var(--text-sm);
		font-weight: 700;
		color: var(--color-text-primary);
	}

	.features-list ul {
		margin: 0;
		padding-left: var(--spacing-4);
		list-style-type: none;
	}

	.features-list li {
		position: relative;
		padding-left: var(--spacing-3);
		margin-bottom: var(--spacing-1);
		font-size: var(--text-sm);
		color: var(--color-text-secondary);
	}

	.features-list li::before {
		content: '✓';
		position: absolute;
		left: 0;
		color: var(--color-primary);
		font-weight: 700;
	}

	.comparison-section {
		margin-bottom: var(--spacing-8);
	}

	.comparison-section h2 {
		font-size: var(--text-2xl);
		font-weight: 700;
		color: var(--color-primary);
		margin-bottom: var(--spacing-4);
	}

	.comparison-table {
		overflow-x: auto;
		border: 1px solid var(--color-border);
		border-radius: var(--radius-lg);
		background: var(--color-bg-secondary);
	}

	table {
		width: 100%;
		border-collapse: collapse;
		font-size: var(--text-sm);
	}

	th {
		background: var(--color-primary);
		color: white;
		padding: var(--spacing-3);
		text-align: left;
		font-weight: 700;
	}

	td {
		padding: var(--spacing-3);
		border-bottom: 1px solid var(--color-border);
	}

	tbody tr:nth-child(odd) {
		background: var(--color-bg-primary);
	}

	tbody tr:hover {
		background: var(--color-bg-tertiary);
	}

	.system-name {
		font-weight: 600;
		color: var(--color-primary);
	}

	.features-info {
		margin-bottom: var(--spacing-8);
	}

	.features-info h2 {
		font-size: var(--text-2xl);
		font-weight: 700;
		color: var(--color-primary);
		margin-bottom: var(--spacing-6);
	}

	.benefits-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
		gap: var(--spacing-4);
	}

	.benefit-icon {
		font-size: 32px;
		margin-bottom: var(--spacing-2);
	}

	.benefit-content h3 {
		margin: 0 0 var(--spacing-2) 0;
		font-size: var(--text-base);
		font-weight: 700;
		color: var(--color-text-primary);
	}

	.benefit-content p {
		margin: 0;
		font-size: var(--text-sm);
		color: var(--color-text-secondary);
		line-height: 1.5;
	}

	@media (max-width: 768px) {
		.products-grid {
			grid-template-columns: 1fr;
		}

		.comparison-table {
			font-size: var(--text-xs);
		}

		th,
		td {
			padding: var(--spacing-2);
		}

		.benefits-grid {
			grid-template-columns: 1fr;
		}
	}
</style>
