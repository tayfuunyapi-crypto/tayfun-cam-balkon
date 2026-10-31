import { supabase } from './supabase';

// Proje kayıtları tarayıcıdan, açık Supabase oturumuyla okunur/yazılır (RLS: authenticated).

export async function getProject(key: string) {
	const { data: record, error } = await supabase
		.from('cb_records')
		.select('*')
		.eq('key', key)
		.eq('kind', 'project')
		.single();

	if (error) throw error;
	return record;
}

export async function updateProjectData(key: string, patch: Record<string, unknown>) {
	const record = await getProject(key);

	const { data: updated, error } = await supabase
		.from('cb_records')
		.update({
			data: { ...record.data, ...patch },
			updated_at: new Date().toISOString()
		})
		.eq('key', key)
		.eq('kind', 'project')
		.eq('deleted', false)
		.select()
		.single();

	if (error) throw error;
	return updated;
}
