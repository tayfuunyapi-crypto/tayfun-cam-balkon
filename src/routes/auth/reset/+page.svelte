<script lang="ts">
	import { auth, isAuthenticated } from '#lib/stores/auth';
	import { goto } from '$app/navigation';

	let password = $state('');
	let passwordAgain = $state('');
	let loading = $state(false);
	let error = $state('');

	async function handleReset(event: SubmitEvent) {
		event.preventDefault();
		if (password.length < 6) {
			error = 'Şifre en az 6 karakter olmalı';
			return;
		}
		if (password !== passwordAgain) {
			error = 'Şifreler aynı değil';
			return;
		}

		loading = true;
		error = '';

		try {
			await auth.updatePassword(password);
			await goto('/');
		} catch (err) {
			error = err instanceof Error ? err.message : 'Şifre güncellenemedi';
		} finally {
			loading = false;
		}
	}
</script>

<div class="auth-page">
	<div class="auth-card">
		<h1>Yeni Şifre</h1>

		{#if $isAuthenticated}
			<p>Tayfun Cam Balkon hesabınız için yeni bir şifre belirleyin.</p>

			<form onsubmit={handleReset}>
				<div class="form-group">
					<label for="password">Yeni şifre</label>
					<input type="password" id="password" bind:value={password} disabled={loading} autocomplete="new-password" />
				</div>

				<div class="form-group">
					<label for="password-again">Yeni şifre (tekrar)</label>
					<input type="password" id="password-again" bind:value={passwordAgain} disabled={loading} autocomplete="new-password" />
				</div>

				{#if error}
					<div class="error">{error}</div>
				{/if}

				<button type="submit" disabled={loading} class="btn-primary">
					{loading ? 'Kaydediliyor...' : 'Şifreyi Kaydet'}
				</button>
			</form>
		{:else}
			<p>
				Bağlantı geçersiz veya süresi dolmuş. Giriş ekranından "Şifremi unuttum" ile yeni bağlantı
				isteyin.
			</p>
			<a class="btn-primary" href="/auth/login">Giriş ekranına dön</a>
		{/if}
	</div>
</div>

<style>
	.auth-page {
		width: 100%;
		min-height: 100vh;
		display: flex;
		align-items: center;
		justify-content: center;
		padding: 1rem;
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
	}

	.auth-card {
		background: white;
		padding: 2rem;
		border-radius: 8px;
		box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
		width: 100%;
		max-width: 400px;
	}

	.auth-card h1 {
		margin: 0 0 0.25rem;
		color: var(--color-primary);
		font-size: 24px;
	}

	.auth-card p {
		margin: 0 0 1.5rem;
		color: var(--color-text-light);
	}

	form {
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}

	.form-group {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	label {
		font-weight: 500;
		color: var(--color-text);
		font-size: 14px;
	}

	input {
		padding: 0.75rem;
		border: 1px solid var(--color-border);
		border-radius: 4px;
		font-size: 14px;
		font-family: inherit;
	}

	input:focus {
		outline: none;
		border-color: var(--color-secondary);
		box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
	}

	.error {
		padding: 0.75rem;
		background: #fee2e2;
		color: #dc2626;
		border-radius: 4px;
		font-size: 14px;
	}

	.btn-primary {
		display: block;
		text-align: center;
		text-decoration: none;
		padding: 0.75rem;
		background: var(--color-secondary);
		color: white;
		border: none;
		border-radius: 4px;
		font-weight: 500;
		cursor: pointer;
		font-size: 14px;
	}

	.btn-primary:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}
</style>
