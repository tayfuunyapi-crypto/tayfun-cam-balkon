<script lang="ts">
	import type { HTMLTextareaAttributes } from 'svelte/elements';

	interface Props extends Omit<HTMLTextareaAttributes, 'value'> {
		label?: string;
		value?: string;
	}

	let { label, value = $bindable(''), rows = 3, ...rest }: Props = $props();
</script>

<label class="field">
	{#if label}<span>{label}</span>{/if}
	<textarea bind:value {rows} {...rest}></textarea>
</label>

<style>
	.field { display: flex; flex-direction: column; gap: var(--spacing-1); margin-bottom: var(--spacing-3); }
	.field span { font-size: var(--text-sm); font-weight: 600; color: var(--color-text-secondary); }
	textarea {
		width: 100%;
		padding: var(--spacing-2) var(--spacing-3);
		border: 1px solid var(--color-border);
		border-radius: var(--radius-md);
		background: var(--color-bg-primary);
		color: var(--color-text-primary);
		font: inherit;
		resize: vertical;
	}
	textarea:focus { outline: 2px solid var(--color-primary-light); outline-offset: -1px; }
</style>
