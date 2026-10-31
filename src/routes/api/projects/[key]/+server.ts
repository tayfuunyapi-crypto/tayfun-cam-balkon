import { json, error as httpError } from '@sveltejs/kit';
import { supabase } from '#lib/supabase';
import type { RequestHandler } from './$types';

export const PUT: RequestHandler = async ({ params, request, locals }) => {
	const { key } = params;
	const body = await request.json();

	try {
		// Get current record
		const { data: record, error: fetchError } = await supabase
			.from('cb_records')
			.select('*')
			.eq('key', key)
			.eq('kind', 'project')
			.single();

		if (fetchError || !record) {
			return httpError(404, 'Project not found');
		}

		// Merge new data with existing data
		const updatedData = {
			...record.data,
			...(body.montage_details !== undefined ? { montage_details: body.montage_details } : {}),
			...(body.daily_tracking !== undefined ? { daily_tracking: body.daily_tracking } : {}),
			status: body.status || record.data?.status
		};

		// Update record
		const { data: updated, error: updateError } = await supabase
			.from('cb_records')
			.update({
				data: updatedData,
				updated_at: new Date().toISOString()
			})
			.eq('key', key)
			.eq('kind', 'project')
			.eq('deleted', false)
			.select()
			.single();

		if (updateError) {
			return httpError(500, `Update failed: ${updateError.message}`);
		}

		return json({ success: true, data: updated });
	} catch (err) {
		const message = err instanceof Error ? err.message : 'Unknown error';
		return httpError(500, message);
	}
};

export const GET: RequestHandler = async ({ params }) => {
	const { key } = params;

	try {
		const { data: record, error } = await supabase
			.from('cb_records')
			.select('*')
			.eq('key', key)
			.eq('kind', 'project')
			.single();

		if (error || !record) {
			return httpError(404, 'Project not found');
		}

		return json({ data: record });
	} catch (err) {
		const message = err instanceof Error ? err.message : 'Unknown error';
		return httpError(500, message);
	}
};
