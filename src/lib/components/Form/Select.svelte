<script lang="ts">
	interface Option {
		value: string;
		label: string;
	}

	interface Props {
		label?: string;
		value?: any;
		options: readonly Option[];
		disabled?: boolean;
	}

	let { label, value = $bindable(), options, disabled = false }: Props = $props();
</script>

<label class="field">
	{#if label}<span>{label}</span>{/if}
	<select bind:value {disabled}>
		{#each options as option (option.value)}
			<option value={option.value}>{option.label}</option>
		{/each}
	</select>
</label>

<style>
	.field { display: flex; flex-direction: column; gap: var(--spacing-1); margin-bottom: var(--spacing-3); }
	.field span { font-size: var(--text-sm); font-weight: 600; color: var(--color-text-secondary); }
	select {
		height: 38px;
		padding: 0 var(--spacing-3);
		border: 1px solid var(--color-border);
		border-radius: var(--radius-md);
		background: var(--color-bg-primary);
		color: var(--color-text-primary);
		font: inherit;
	}
</style>
