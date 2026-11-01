<script lang="ts">
	import type { Snippet } from 'svelte';
	import { X } from '@lucide/svelte';

	interface Props {
		title: string;
		onclose?: () => void;
		children?: Snippet;
	}

	let { title, onclose, children }: Props = $props();
</script>

<svelte:window onkeydown={(e) => e.key === 'Escape' && onclose?.()} />

<!-- svelte-ignore a11y_click_events_have_key_events, a11y_no_static_element_interactions -->
<div class="backdrop" onclick={(e) => e.target === e.currentTarget && onclose?.()}>
	<div class="modal" role="dialog" aria-modal="true" aria-label={title}>
		<header>
			<h2>{title}</h2>
			<button class="close" onclick={() => onclose?.()} aria-label="Kapat"><X size={18} /></button>
		</header>
		<div class="body">
			{@render children?.()}
		</div>
	</div>
</div>

<style>
	.backdrop {
		position: fixed;
		inset: 0;
		z-index: 100;
		display: flex;
		align-items: center;
		justify-content: center;
		padding: var(--spacing-4);
		background: rgba(15, 23, 42, 0.45);
	}
	.modal {
		width: min(640px, 100%);
		max-height: calc(100vh - 32px);
		overflow-y: auto;
		background: var(--color-bg-primary);
		border-radius: var(--radius-lg);
		box-shadow: 0 20px 50px rgba(0, 0, 0, 0.25);
	}
	header {
		display: flex;
		align-items: center;
		justify-content: space-between;
		padding: var(--spacing-4) var(--spacing-6);
		border-bottom: 1px solid var(--color-border);
	}
	h2 { margin: 0; font-size: var(--text-lg); }
	.close { border: 0; background: none; cursor: pointer; color: var(--color-text-secondary); padding: var(--spacing-1); }
	.body { padding: var(--spacing-6); }
</style>
