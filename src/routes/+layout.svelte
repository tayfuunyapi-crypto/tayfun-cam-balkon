<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/state';
	import favicon from '#lib/assets/favicon.svg';
	import AppSidebar from '#lib/components/AppSidebar.svelte';
	import { auth } from '#lib/stores/auth';
	import { isAuthenticated } from '#lib/stores/auth';
	import { data } from '#lib/stores/data';
	import type { LayoutProps } from './$types';

	let { children }: LayoutProps = $props();
	let initialized = $state(false);

	let unsubscribeAuth: (() => void) | undefined;
	let unsubscribeRealtime: (() => void) | undefined;

	onMount(() => {
		auth.initialize().then((unsubscribe) => {
			unsubscribeAuth = unsubscribe;
			initialized = true;
		});

		return () => {
			unsubscribeAuth?.();
			unsubscribeRealtime?.();
		};
	});

	const publicPaths = ['/', '/auth/login', '/auth/reset'];

	$effect(() => {
		if (initialized && !$isAuthenticated && !publicPaths.includes(page.url.pathname)) {
			goto('/auth/login', { replaceState: true });
		}
	});

	// Veriler RLS nedeniyle yalnızca Supabase oturumu açıkken okunabilir
	$effect(() => {
		if (!$isAuthenticated) return;

		data.loadAll();
		unsubscribeRealtime = data.setupRealtimeListeners();

		return () => {
			unsubscribeRealtime?.();
			unsubscribeRealtime = undefined;
		};
	});
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<title>Tayfun Cam Balkon</title>
	<meta name="description" content="Web-based glass balcony design system" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
</svelte:head>

<style>
	:global(:root) {
		--color-primary: #1f2937;
		--color-secondary: #10b981;
		--color-border: #e5e7eb;
		--color-text: #111827;
		--color-text-light: #6b7280;
		/* Tablo/rapor sayfalarının (FAZE 5) bileşen değişkenleri */
		--color-primary-light: #93c5fd;
		--color-text-primary: #111827;
		--color-text-secondary: #6b7280;
		--color-text-tertiary: #9ca3af;
		--color-bg-primary: #ffffff;
		--color-bg-secondary: #f9fafb;
		--color-bg-tertiary: #f3f4f6;
		--color-danger: #dc2626;
		--color-danger-light: #fee2e2;
		--spacing-1: 4px;
		--spacing-2: 8px;
		--spacing-3: 12px;
		--spacing-4: 16px;
		--spacing-6: 24px;
		--spacing-8: 32px;
		--spacing-12: 48px;
		--radius-sm: 4px;
		--radius-md: 8px;
		--radius-lg: 12px;
		--text-xs: 12px;
		--text-sm: 13px;
		--text-base: 14px;
		--text-lg: 18px;
		--text-2xl: 24px;
	}

	:global(body) {
		margin: 0;
		padding: 0;
		font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
		font-size: 14px;
		line-height: 1.5;
		color: var(--color-text);
		background: #f4f6f8;
	}

	:global(html, body) { min-height: 100%; }

	:global(*) {
		box-sizing: border-box;
	}

	@keyframes spin {
		to { transform: rotate(360deg); }
	}

	.app-shell {
		display: flex;
		min-height: 100dvh;
		background: #f4f6f8;
	}

	.app-content {
		flex: 1;
		min-width: 0;
		min-height: 100dvh;
		overflow-x: hidden;
	}
</style>

{#if initialized}
	{#if $isAuthenticated && !page.url.pathname.startsWith('/auth/')}
		<div class="app-shell">
			<AppSidebar />
			<main class="app-content">{@render children()}</main>
		</div>
	{:else}
		{@render children()}
	{/if}
{:else}
	<div style="display: flex; align-items: center; justify-content: center; height: 100vh;">
		<div style="text-align: center;">
			<div style="width: 40px; height: 40px; border: 4px solid var(--color-border); border-top-color: var(--color-secondary); border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto 1rem;"></div>
			<p>Yükleniyor...</p>
		</div>
	</div>
{/if}
