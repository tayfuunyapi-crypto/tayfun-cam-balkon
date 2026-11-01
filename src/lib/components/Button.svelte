<script lang="ts">
	import type { Snippet } from 'svelte';
	import type { HTMLButtonAttributes } from 'svelte/elements';

	interface Props extends HTMLButtonAttributes {
		variant?: 'primary' | 'secondary' | 'danger' | 'ghost';
		children?: Snippet;
	}

	let { variant = 'primary', type = 'button', children, class: className = '', ...rest }: Props = $props();
</script>

<button {type} class="btn {variant} {className}" {...rest}>
	{@render children?.()}
</button>

<style>
	.btn {
		display: inline-flex;
		align-items: center;
		gap: var(--spacing-2);
		height: 38px;
		padding: 0 var(--spacing-4);
		border: 1px solid transparent;
		border-radius: var(--radius-md);
		font: inherit;
		font-weight: 600;
		cursor: pointer;
		white-space: nowrap;
	}
	.btn:disabled { opacity: 0.55; cursor: not-allowed; }
	.primary { background: var(--color-secondary); color: #fff; }
	.primary:hover:not(:disabled) { background: #059669; }
	.secondary { background: var(--color-bg-primary); color: var(--color-text-primary); border-color: var(--color-border); }
	.secondary:hover:not(:disabled) { background: var(--color-bg-secondary); }
	.danger { background: var(--color-danger); color: #fff; }
	.danger:hover:not(:disabled) { background: #b91c1c; }
	.ghost { background: transparent; color: var(--color-text-secondary); }
</style>
