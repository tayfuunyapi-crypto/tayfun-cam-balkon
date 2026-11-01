import type { Project } from '#lib/types/models';
import { statusInfo } from '#lib/workflow';
import { createRecordStore, num, text } from './records';

const base = createRecordStore<Project>(
	'project',
	'p',
	(key, d, updatedAt) => ({
		id: key,
		name: text(d.name),
		customer: text(d.customer),
		description: text(d.description),
		status: statusInfo(d.status).code,
		budget: num(d.pricing?.total ?? d.price),
		timeline: num(d.timeline),
		notes: text(d.notes),
		createdAt: text(d.created_at || updatedAt),
		updatedAt
	}),
	// customer alanı formda yok; yazılmaz, mevcut değer korunur
	(p) => ({
		name: text(p.name).trim(),
		description: text(p.description),
		status: statusInfo(p.status).code,
		price: num(p.budget),
		timeline: num(p.timeline),
		notes: text(p.notes)
	})
);

export const projectStore = {
	subscribe: base.subscribe,
	loadAll: base.loadAll,
	addProject: base.add,
	updateProject: base.update,
	deleteProject: base.remove
};
