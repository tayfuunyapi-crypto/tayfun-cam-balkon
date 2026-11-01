<script lang="ts">
	import type { Snippet } from 'svelte';

	let { title, children }: { title: string; children?: Snippet } = $props();
</script>

<svelte:head><title>{title} | Tayfun Yapı</title></svelte:head>

<div class="page">
	<h1>{title}</h1>
	{@render children?.()}
</div>

<style>
	.page { padding: var(--spacing-6); max-width: 1400px; margin: 0 auto; }
	h1 { margin: 0 0 var(--spacing-6); font-size: var(--text-2xl); color: var(--color-text-primary); }
	@media (max-width: 768px) { .page { padding: var(--spacing-4); } }
</style>
