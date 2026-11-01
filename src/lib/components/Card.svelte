<script lang="ts">
	import type { Snippet } from 'svelte';

	interface Props {
		variant?: 'primary' | 'success' | 'plain';
		children?: Snippet;
	}

	let { variant = 'plain', children }: Props = $props();
</script>

<div class="card {variant}">
	{@render children?.()}
</div>

<style>
	.card {
		display: flex;
		align-items: center;
		gap: var(--spacing-4);
		padding: var(--spacing-4);
		background: var(--color-bg-primary);
		border: 1px solid var(--color-border);
		border-radius: var(--radius-lg);
	}
	.primary { border-left: 4px solid var(--color-primary); }
	.success { border-left: 4px solid var(--color-secondary); }
</style>
