<script lang="ts">
	import { data } from '#lib/stores/data';
	import { updateProjectData } from '#lib/project-records';
	import { recordData, statusInfo, formatMoney } from '#lib/workflow';
	import { ChevronLeft, Clock, MapPin, User, Image as IconImage, Save, AlertCircle, Check, X } from '@lucide/svelte';

	import { page } from '$app/state';
	const params = $derived(page.params);
	let project = $state<any>(null);
	let dailyTracking = $state({
		entries: [] as any[],
		photos: [] as any[],
		notes: '',
		customerSignature: '',
		date: new Date().toISOString().split('T')[0]
	});

	let activeEntry = $state<number | null>(null);
	let checkedIn = $state(false);
	let checkInTime = $state<string>('');
	let checkOutTime = $state<string>('');
	let photos: File[] = $state([]);
	let saving = $state(false);

	data.subscribe(dataStore => {
		const proj = params.key ? dataStore.projects[params.key] : null;
		project = proj;

		if (proj?.data?.daily_tracking) {
			dailyTracking = proj.data.daily_tracking;
		}
	});

	function getCurrentTime() {
		const now = new Date();
		return now.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
	}

	function handleCheckIn() {
		if (checkedIn) {
			// Check out
			checkOutTime = getCurrentTime();
			const duration = calculateDuration(checkInTime, checkOutTime);

			const entry = {
				id: Date.now(),
				date: dailyTracking.date,
				checkIn: checkInTime,
				checkOut: checkOutTime,
				duration,
				workers: [],
				tasks: ''
			};

			dailyTracking.entries = [...dailyTracking.entries, entry];
			activeEntry = dailyTracking.entries.length - 1;
			checkedIn = false;
			checkInTime = '';
			checkOutTime = '';
		} else {
			// Check in
			checkedIn = true;
			checkInTime = getCurrentTime();
		}
	}

	function calculateDuration(start: string, end: string): string {
		const [sh, sm, ss] = start.split(':').map(Number);
		const [eh, em, es] = end.split(':').map(Number);

		let startMin = sh * 60 + sm;
		let endMin = eh * 60 + em;

		if (endMin < startMin) {
			endMin += 24 * 60; // Next day
		}

		const diffMin = endMin - startMin;
		const hours = Math.floor(diffMin / 60);
		const mins = diffMin % 60;

		return `${hours}s ${mins}d`;
	}

	function handlePhotoUpload(event: Event) {
		const input = event.target as HTMLInputElement;
		if (input.files) {
			photos = [...photos, ...Array.from(input.files)];
		}
	}

	function removePhoto(idx: number) {
		photos = photos.filter((_, i) => i !== idx);
	}

	function updateEntryNotes(idx: number, notes: string) {
		if (dailyTracking.entries[idx]) {
			dailyTracking.entries[idx].tasks = notes;
		}
	}

	async function saveDailyTracking() {
		if (!project) return;
		saving = true;

		try {
			await updateProjectData(project.key, { daily_tracking: dailyTracking });
			await data.loadAll();
			alert('Gün takibi kaydedildi!');
		} catch (error) {
			console.error('Error saving:', error);
			alert('Hata: Veriler kaydedilemedi');
		} finally {
			saving = false;
		}
	}
</script>

<svelte:head>
	<title>Montaj Gün Takibi | Tayfun Yapı</title>
</svelte:head>

<div class="page">
	{#if !project}
		<div class="loading">
			<AlertCircle size={32} />
			<p>Proje yükleniyor...</p>
		</div>
	{:else}
		<header>
			<a href="/montage/{params.key}" class="back">
				<ChevronLeft size={20} />
				<span>Geri</span>
			</a>
			<div>
				<span>OPERASYON</span>
				<h1>Montaj Gün Takibi</h1>
				<p>{project?.data?.name || 'Proje'}</p>
			</div>
		</header>

		<div class="content">
			<!-- Check-in/Check-out Section -->
			<section class="card">
				<h2>Zaman Takibi</h2>
				<div class="checkin-section">
					<div class="time-display">
						<div class="time-info">
							<span class="label">Şu An</span>
							<span class="time">{new Date().toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' })}</span>
						</div>
						{#if checkedIn}
							<div class="status active">
								<Clock size={16} />
								<span>Çalışmada</span>
							</div>
							<div class="time-info">
								<span class="label">Giriş Saati</span>
								<span class="time">{checkInTime}</span>
							</div>
						{:else}
							<div class="status">
								<Clock size={16} />
								<span>Hazır</span>
							</div>
						{/if}
					</div>

					<button
						onclick={handleCheckIn}
						class={checkedIn ? 'btn-checkout' : 'btn-checkin'}
					>
						{#if checkedIn}
							<X size={18} />
							<span>Çıkış Yap</span>
						{:else}
							<Check size={18} />
							<span>Giriş Yap</span>
						{/if}
					</button>
				</div>
			</section>

			<!-- Daily Entries -->
			<section class="card">
				<h2>Gün İçindeki Çalışmalar</h2>
				<div class="entries-list">
					{#if dailyTracking.entries.length > 0}
						{#each dailyTracking.entries as entry, idx}
							<div class="entry-item" class:active={activeEntry === idx}>
								<div class="entry-header" onclick={() => activeEntry === idx ? activeEntry = null : activeEntry = idx}>
									<div class="time-range">
										<Clock size={16} />
										<span>{entry.checkIn} - {entry.checkOut || '-'}</span>
									</div>
									<span class="duration">{entry.duration}</span>
								</div>
								{#if activeEntry === idx}
									<div class="entry-details">
										<label>
											<span class="label">Yapılan İşler</span>
											<textarea
												value={entry.tasks || ''}
												onchange={(e) => updateEntryNotes(idx, (e.target as HTMLTextAreaElement).value)}
												placeholder="Montaj sırasında yapılan işleri detaylı olarak açıklayınız..."
											></textarea>
										</label>
									</div>
								{/if}
							</div>
						{/each}
					{:else}
						<div class="empty">
							<AlertCircle size={24} />
							<p>Henüz kayıt bulunmamaktadır</p>
						</div>
					{/if}
				</div>
			</section>

			<!-- Photo Upload -->
			<section class="card">
				<h2>Fotoğraflar</h2>
				<div class="photo-upload">
					<label class="upload-area">
						<IconImage size={32} />
						<span>Fotoğraf seç veya sürükle</span>
						<input type="file" multiple accept="image/*" onchange={handlePhotoUpload} />
					</label>
				</div>
				{#if photos.length > 0}
					<div class="photo-grid">
						{#each photos as photo, idx}
							<div class="photo-item">
								<div class="photo-preview">
									<img src={URL.createObjectURL(photo)} alt="Preview" />
								</div>
								<button
									class="remove-photo"
									onclick={() => removePhoto(idx)}
									title="Kaldır"
								>
									<X size={14} />
								</button>
								<span class="photo-name">{photo.name}</span>
							</div>
						{/each}
					</div>
				{/if}
			</section>

			<!-- Notes Section -->
			<section class="card">
				<h2>Genel Notlar</h2>
				<label>
					<span class="label">Günlük Notlar</span>
					<textarea
						bind:value={dailyTracking.notes}
						placeholder="Oluşan sorunlar, müşteri talepleri, ek bilgiler..."
					></textarea>
				</label>
			</section>

			<!-- Customer Signature -->
			<section class="card">
				<h2>Müşteri Onayı</h2>
				<div class="signature-section">
					<label>
						<span class="label">Müşteri Adı/İmzası</span>
						<input
							type="text"
							bind:value={dailyTracking.customerSignature}
							placeholder="Müşteri adı ve imza (el yazısı fotoğrafı eklenebilir)"
						/>
					</label>
				</div>
			</section>

			<!-- Action Buttons -->
			<div class="actions">
				<button onclick={() => window.history.back()}>Geri Dön</button>
				<button onclick={saveDailyTracking} disabled={saving} class="primary">
					<Save size={17} />
					{saving ? 'Kaydediliyor...' : 'Kaydet'}
				</button>
			</div>
		</div>
	{/if}
</div>

<style>
	.page {
		max-width: 1000px;
		margin: auto;
		padding: 30px 20px;
		background: #f8fbfb;
		min-height: 100vh;
	}

	header {
		display: flex;
		align-items: center;
		gap: 16px;
		margin-bottom: 30px;
		padding-bottom: 20px;
		border-bottom: 2px solid #dfe4e8;
	}

	.back {
		display: flex;
		align-items: center;
		gap: 8px;
		padding: 8px 12px;
		background: white;
		border: 1px solid #dfe4e8;
		border-radius: 6px;
		color: #0f7c80;
		text-decoration: none;
		font-weight: 600;
		font-size: 13px;
		cursor: pointer;
		transition: all 0.2s;
	}

	.back:hover {
		background: #f0f4f7;
	}

	header > div {
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
	}

	header p {
		font-size: 13px;
		color: #666;
		margin: 0;
	}

	.content {
		display: flex;
		flex-direction: column;
		gap: 20px;
	}

	.card {
		background: white;
		border: 1px solid #dfe4e8;
		border-radius: 8px;
		padding: 24px;
	}

	.card h2 {
		font-size: 16px;
		color: #0f7c80;
		margin: 0 0 16px;
		padding-bottom: 12px;
		border-bottom: 1px solid #dfe4e8;
	}

	.checkin-section {
		display: flex;
		align-items: center;
		gap: 20px;
	}

	.time-display {
		flex: 1;
		display: flex;
		align-items: center;
		gap: 16px;
		padding: 16px;
		background: #f0f9f8;
		border-radius: 6px;
	}

	.time-info {
		display: flex;
		flex-direction: column;
		gap: 4px;
	}

	.label {
		font-size: 11px;
		color: #666;
		font-weight: bold;
		text-transform: uppercase;
	}

	.time {
		font-size: 20px;
		font-weight: bold;
		color: #0f7c80;
	}

	.status {
		display: flex;
		align-items: center;
		gap: 8px;
		padding: 8px 12px;
		background: #edf0f2;
		color: #666;
		border-radius: 20px;
		font-size: 12px;
		font-weight: 600;
	}

	.status.active {
		background: #d1f4f3;
		color: #0f7c80;
	}

	.btn-checkin,
	.btn-checkout {
		display: flex;
		align-items: center;
		gap: 8px;
		padding: 12px 24px;
		border: none;
		border-radius: 6px;
		font-weight: 600;
		font-size: 13px;
		cursor: pointer;
		transition: all 0.2s;
	}

	.btn-checkin {
		background: #10b981;
		color: white;
	}

	.btn-checkin:hover {
		background: #059669;
	}

	.btn-checkout {
		background: #ef4444;
		color: white;
	}

	.btn-checkout:hover {
		background: #dc2626;
	}

	.entries-list {
		display: flex;
		flex-direction: column;
		gap: 12px;
	}

	.entry-item {
		border: 1px solid #dfe4e8;
		border-radius: 6px;
		overflow: hidden;
		transition: all 0.2s;
	}

	.entry-item.active {
		border-color: #0f7c80;
		background: #f0f9f8;
	}

	.entry-header {
		display: flex;
		align-items: center;
		justify-content: space-between;
		padding: 12px 16px;
		cursor: pointer;
		background: white;
		transition: all 0.2s;
	}

	.entry-item.active .entry-header {
		background: #f0f9f8;
	}

	.time-range {
		display: flex;
		align-items: center;
		gap: 8px;
		font-size: 13px;
		font-weight: 600;
		color: #25313a;
	}

	.duration {
		font-size: 12px;
		color: #0f7c80;
		font-weight: 700;
		background: white;
		padding: 4px 8px;
		border-radius: 4px;
	}

	.entry-details {
		padding: 16px;
		background: white;
		border-top: 1px solid #dfe4e8;
	}

	.entry-details label {
		display: flex;
		flex-direction: column;
		gap: 8px;
	}

	textarea,
	input[type="text"] {
		width: 100%;
		padding: 10px;
		border: 1px solid #dfe4e8;
		border-radius: 4px;
		font-size: 13px;
		font-family: inherit;
	}

	textarea {
		min-height: 100px;
		resize: vertical;
	}

	textarea:focus,
	input:focus {
		outline: none;
		border-color: #0f7c80;
		box-shadow: 0 0 0 3px rgba(15, 124, 128, 0.1);
	}

	.photo-upload {
		margin-bottom: 16px;
	}

	.upload-area {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 12px;
		padding: 40px;
		border: 2px dashed #dfe4e8;
		border-radius: 8px;
		background: #f8fbfb;
		cursor: pointer;
		transition: all 0.2s;
		color: #7b8791;
		font-weight: 600;
		font-size: 13px;
	}

	.upload-area:hover {
		border-color: #0f7c80;
		background: #f0f9f8;
		color: #0f7c80;
	}

	.upload-area input {
		display: none;
	}

	.photo-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
		gap: 16px;
		margin-top: 16px;
	}

	.photo-item {
		position: relative;
		border-radius: 6px;
		overflow: hidden;
		background: #f0f2f5;
	}

	.photo-preview {
		width: 100%;
		aspect-ratio: 1;
		overflow: hidden;
		background: #eee;
	}

	.photo-preview img {
		width: 100%;
		height: 100%;
		object-fit: cover;
	}

	.remove-photo {
		position: absolute;
		top: 4px;
		right: 4px;
		display: flex;
		align-items: center;
		justify-content: center;
		width: 24px;
		height: 24px;
		background: #dc2626;
		color: white;
		border: none;
		border-radius: 4px;
		cursor: pointer;
		opacity: 0;
		transition: all 0.2s;
	}

	.photo-item:hover .remove-photo {
		opacity: 1;
	}

	.photo-name {
		display: block;
		padding: 8px;
		font-size: 11px;
		color: #666;
		text-overflow: ellipsis;
		overflow: hidden;
		white-space: nowrap;
	}

	.signature-section label {
		display: flex;
		flex-direction: column;
		gap: 8px;
	}

	.empty {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		padding: 40px 20px;
		color: #999;
		text-align: center;
	}

	.actions {
		display: flex;
		gap: 12px;
		justify-content: flex-end;
		padding: 20px;
		background: white;
		border-radius: 8px;
		border: 1px solid #dfe4e8;
	}

	.actions button {
		padding: 10px 20px;
		border: 1px solid #dfe4e8;
		background: white;
		border-radius: 6px;
		cursor: pointer;
		font-weight: 600;
		font-size: 13px;
		transition: all 0.2s;
	}

	.actions button:hover {
		background: #f0f4f7;
	}

	.actions button.primary {
		display: flex;
		align-items: center;
		gap: 8px;
		background: #0f7c80;
		color: white;
		border-color: #0f7c80;
	}

	.actions button.primary:hover {
		background: #0d6a6e;
	}

	.actions button:disabled {
		opacity: 0.5;
		cursor: not-allowed;
	}

	.loading {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		min-height: 400px;
		color: #666;
		gap: 12px;
	}

	@media (max-width: 768px) {
		.page {
			padding: 20px 15px;
		}

		header {
			flex-wrap: wrap;
		}

		.checkin-section {
			flex-direction: column;
		}

		.time-display {
			width: 100%;
		}

		.photo-grid {
			grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
		}

		.actions {
			flex-direction: column;
		}

		.actions button {
			width: 100%;
		}
	}
</style>
