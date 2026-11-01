<script lang="ts">
	import { X } from '@lucide/svelte';
	import { toastStore, type ToastItem } from '#lib/stores/toastStore';

	let { notifications = [] }: { notifications?: ToastItem[] } = $props();
</script>

<div class="toasts" aria-live="polite">
	{#each notifications as toast (toast.id)}
		<div class="toast {toast.type}" role="status">
			<div>
				<strong>{toast.title}</strong>
				<p>{toast.message}</p>
			</div>
			<button onclick={() => toastStore.removeToast(toast.id)} aria-label="Kapat"><X size={16} /></button>
		</div>
	{/each}
</div>

<style>
	.toasts {
		position: fixed;
		right: 16px;
		bottom: 16px;
		z-index: 200;
		display: flex;
		flex-direction: column;
		gap: var(--spacing-2);
		width: min(360px, calc(100vw - 32px));
	}
	.toast {
		display: flex;
		align-items: flex-start;
		justify-content: space-between;
		gap: var(--spacing-3);
		padding: var(--spacing-3) var(--spacing-4);
		background: var(--color-bg-primary);
		border: 1px solid var(--color-border);
		border-left: 4px solid var(--color-primary);
		border-radius: var(--radius-md);
		box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
	}
	.success { border-left-color: var(--color-secondary); }
	.error { border-left-color: var(--color-danger); }
	.warning { border-left-color: #d97706; }
	strong { font-size: var(--text-sm); }
	p { margin: 2px 0 0; font-size: var(--text-sm); color: var(--color-text-secondary); }
	button { border: 0; background: none; cursor: pointer; color: var(--color-text-secondary); padding: 0; }
</style>
