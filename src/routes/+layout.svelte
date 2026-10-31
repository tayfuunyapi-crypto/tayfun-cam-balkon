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
