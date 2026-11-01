<script lang="ts">
	import { ChevronUp, ChevronDown, Trash2, Edit2 } from '@lucide/svelte';

	interface Column<T> {
		key: keyof T;
		label: string;
		sortable?: boolean;
		format?: (value: any) => string;
		width?: string;
	}

	interface Props<T> {
		data: T[];
		columns: Column<T>[];
		selectable?: boolean;
		hoverable?: boolean;
		striped?: boolean;
		onEdit?: (item: T) => void;
		onDelete?: (item: T) => void;
		selectedItems?: Set<any>;
		onSelectionChange?: (items: Set<any>) => void;
	}

	let {
		data,
		columns,
		selectable = false,
		hoverable = true,
		striped = true,
		onEdit,
		onDelete,
		selectedItems = new Set(),
		onSelectionChange
	}: Props<any> = $props();

	let sortColumn = $state<keyof any | null>(null);
	let sortDirection = $state<'asc' | 'desc'>('asc');

	function toggleSort(column: Column<any>) {
		if (!column.sortable) return;

		if (sortColumn === column.key) {
			sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
		} else {
			sortColumn = column.key;
			sortDirection = 'asc';
		}
	}

	let sortedData = $derived.by(() => {
		if (!sortColumn) return data;

		const sorted = [...data].sort((a, b) => {
			const aVal = a[sortColumn];
			const bVal = b[sortColumn];

			if (aVal < bVal) return sortDirection === 'asc' ? -1 : 1;
			if (aVal > bVal) return sortDirection === 'asc' ? 1 : -1;
			return 0;
		});

		return sorted;
	});

	function toggleSelectAll() {
		if (selectedItems.size === data.length) {
			selectedItems.clear();
		} else {
			selectedItems = new Set(data);
		}
		onSelectionChange?.(selectedItems);
	}

	function toggleSelect(item: any) {
		if (selectedItems.has(item)) {
			selectedItems.delete(item);
		} else {
			selectedItems.add(item);
		}
		selectedItems = new Set(selectedItems);
		onSelectionChange?.(selectedItems);
	}

	function formatValue(column: Column<any>, item: any) {
		const value = item[column.key];
		return column.format ? column.format(value) : value;
	}
</script>

<div class="table-wrapper">
	<table class:striped class:hoverable>
		<thead>
			<tr>
				{#if selectable}
					<th class="checkbox-col">
						<input
							type="checkbox"
							checked={selectedItems.size === data.length && data.length > 0}
							onchange={toggleSelectAll}
							aria-label="Hepsini seç"
						/>
					</th>
				{/if}
				{#each columns as column (column.key)}
					<th
						style={column.width ? `width: ${column.width}` : ''}
						class:sortable={column.sortable}
						onclick={() => toggleSort(column)}
						role={column.sortable ? 'button' : undefined}
						tabindex={column.sortable ? 0 : undefined}
						onkeydown={(e) => {
							if ((e.key === 'Enter' || e.key === ' ') && column.sortable) {
								toggleSort(column);
							}
						}}
					>
						<div class="header-content">
							<span>{column.label}</span>
							{#if column.sortable}
								<div class="sort-icon">
									{#if sortColumn === column.key}
										{#if sortDirection === 'asc'}
											<ChevronUp size={16} />
										{:else}
											<ChevronDown size={16} />
										{/if}
									{/if}
								</div>
							{/if}
						</div>
					</th>
				{/each}
				{#if onEdit || onDelete}
					<th class="actions-col">İşlemler</th>
				{/if}
			</tr>
		</thead>
		<tbody>
			{#if sortedData.length === 0}
				<tr class="empty-row">
					<td colspan={columns.length + (selectable ? 1 : 0) + (onEdit || onDelete ? 1 : 0)}>
						<div class="empty-state">
							<p>Veri bulunamadı</p>
						</div>
					</td>
				</tr>
			{:else}
				{#each sortedData as item, idx (item.id || idx)}
					<tr class:selected={selectedItems.has(item)}>
						{#if selectable}
							<td class="checkbox-col">
								<input
									type="checkbox"
									checked={selectedItems.has(item)}
									onchange={() => toggleSelect(item)}
									aria-label="Seç"
								/>
							</td>
						{/if}
						{#each columns as column (column.key)}
							<td data-label={column.label}>
								{formatValue(column, item)}
							</td>
						{/each}
						{#if onEdit || onDelete}
							<td class="actions-col">
								<div class="action-buttons">
									{#if onEdit}
										<button
											class="action-btn edit"
											onclick={() => onEdit(item)}
											title="Düzenle"
											aria-label="Düzenle"
										>
											<Edit2 size={16} />
										</button>
									{/if}
									{#if onDelete}
										<button
											class="action-btn delete"
											onclick={() => onDelete(item)}
											title="Sil"
											aria-label="Sil"
										>
											<Trash2 size={16} />
										</button>
									{/if}
								</div>
							</td>
						{/if}
					</tr>
				{/each}
			{/if}
		</tbody>
	</table>
</div>

<style>
	.table-wrapper {
		width: 100%;
		overflow-x: auto;
		border: 1px solid var(--color-border);
		border-radius: var(--radius-md);
		background: var(--color-bg-secondary);
	}

	table {
		width: 100%;
		border-collapse: collapse;
		font-size: var(--text-sm);
	}

	thead {
		background: var(--color-bg-secondary);
		border-bottom: 2px solid var(--color-border);
		position: sticky;
		top: 0;
		z-index: 10;
	}

	th {
		padding: var(--spacing-3) var(--spacing-4);
		text-align: left;
		font-weight: 700;
		color: var(--color-text-primary);
		user-select: none;
	}

	th.sortable {
		cursor: pointer;
		transition: background-color 200ms;
	}

	th.sortable:hover {
		background-color: var(--color-bg-tertiary);
	}

	.header-content {
		display: flex;
		align-items: center;
		gap: var(--spacing-2);
	}

	.sort-icon {
		display: flex;
		align-items: center;
		color: var(--color-text-secondary);
		transition: color 200ms;
	}

	th.sortable:hover .sort-icon {
		color: var(--color-primary);
	}

	td {
		padding: var(--spacing-3) var(--spacing-4);
		color: var(--color-text-secondary);
		border-bottom: 1px solid var(--color-border);
	}

	table.striped tbody tr:nth-child(odd) {
		background: var(--color-bg-primary);
	}

	table.hoverable tbody tr:hover {
		background: var(--color-bg-tertiary);
	}

	tr.selected {
		background: var(--color-primary-light) !important;
	}

	.checkbox-col {
		width: 50px;
		text-align: center;
	}

	.checkbox-col input {
		cursor: pointer;
		width: 18px;
		height: 18px;
	}

	.actions-col {
		width: 120px;
		text-align: center;
	}

	.action-buttons {
		display: flex;
		gap: var(--spacing-2);
		justify-content: center;
	}

	.action-btn {
		padding: var(--spacing-2);
		border: none;
		background: transparent;
		border-radius: var(--radius-sm);
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
		transition: all 200ms;
	}

	.action-btn.edit {
		color: var(--color-primary);
	}

	.action-btn.edit:hover {
		background: var(--color-primary-light);
	}

	.action-btn.delete {
		color: var(--color-danger);
	}

	.action-btn.delete:hover {
		background: var(--color-danger-light);
	}

	.empty-row td {
		padding: var(--spacing-8) var(--spacing-4);
		border-bottom: none;
	}

	.empty-state {
		text-align: center;
		color: var(--color-text-tertiary);
	}

	@media (max-width: 768px) {
		th,
		td {
			padding: var(--spacing-2) var(--spacing-3);
		}

		.header-content {
			flex-direction: column;
			gap: var(--spacing-1);
		}

		.actions-col {
			width: auto;
		}
	}
</style>
