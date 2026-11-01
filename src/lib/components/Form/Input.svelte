<script lang="ts">
	import type { HTMLInputAttributes } from 'svelte/elements';

	interface Props extends Omit<HTMLInputAttributes, 'value'> {
		label?: string;
		value?: any;
	}

	let { label, value = $bindable(), class: className = '', ...rest }: Props = $props();
</script>

{#if label}
	<label class="field">
		<span>{label}{#if rest.required}<b> *</b>{/if}</span>
		<input class="control {className}" bind:value {...rest} />
	</label>
{:else}
	<input class="control {className}" bind:value {...rest} />
{/if}

<style>
	.field { display: flex; flex-direction: column; gap: var(--spacing-1); margin-bottom: var(--spacing-3); }
	.field span { font-size: var(--text-sm); font-weight: 600; color: var(--color-text-secondary); }
	.field b { color: var(--color-danger); }
	.control {
		width: 100%;
		height: 38px;
		padding: 0 var(--spacing-3);
		border: 1px solid var(--color-border);
		border-radius: var(--radius-md);
		background: var(--color-bg-primary);
		color: var(--color-text-primary);
		font: inherit;
	}
	.control:focus { outline: 2px solid var(--color-primary-light); outline-offset: -1px; }
</style>
