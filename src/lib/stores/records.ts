import { writable } from 'svelte/store';
import { supabase } from '#lib/supabase';

type Kind = 'customer' | 'project' | 'quote';
type Row = { key: string; data: Record<string, any> | null; updated_at: string | null };

// Tek bir cb_records türü için liste deposu. Güncellemede mevcut data korunur, yalnızca
// formdaki alanlar üzerine yazılır; masaüstü/mobilin yazdığı diğer alanlar kaybolmaz.
export function createRecordStore<T extends { id: string }>(
	kind: Kind,
	keyPrefix: string,
	fromRow: (key: string, data: Record<string, any>, updatedAt: string) => T,
	toData: (item: Partial<T>) => Record<string, unknown>
) {
	const store = writable<{ items: T[] }>({ items: [] });

	async function loadAll() {
		const { data, error } = await supabase
			.from('cb_records')
			.select('key, data, updated_at')
			.eq('kind', kind)
			.eq('deleted', false)
			.order('updated_at', { ascending: false });
		if (error) throw error;
		store.set({
			items: ((data ?? []) as Row[]).map((r) => fromRow(r.key, r.data ?? {}, r.updated_at ?? ''))
		});
	}

	async function add(item: Partial<T>) {
		const { error } = await supabase.from('cb_records').insert({
			key: `${keyPrefix}-${Date.now()}`,
			kind,
			data: { ...toData(item), created_at: new Date().toISOString() },
			origin: 'web',
			deleted: false
		});
		if (error) throw error;
		await loadAll();
	}

	async function update(id: string, item: Partial<T>) {
		const { data: current, error: readError } = await supabase
			.from('cb_records')
			.select('data')
			.eq('key', id)
			.eq('kind', kind)
			.single();
		if (readError) throw readError;
		const { error } = await supabase
			.from('cb_records')
			.update({ data: { ...(current?.data ?? {}), ...toData(item) }, updated_at: new Date().toISOString() })
			.eq('key', id)
			.eq('kind', kind)
			.eq('deleted', false);
		if (error) throw error;
		await loadAll();
	}

	async function remove(id: string) {
		const { error } = await supabase
			.from('cb_records')
			.update({ deleted: true, updated_at: new Date().toISOString() })
			.eq('key', id)
			.eq('kind', kind);
		if (error) throw error;
		store.update((s) => ({ items: s.items.filter((item) => item.id !== id) }));
	}

	return { subscribe: store.subscribe, loadAll, add, update, remove };
}

export const text = (value: unknown) => (value == null ? '' : String(value));
export const num = (value: unknown) => Number(value) || 0;
