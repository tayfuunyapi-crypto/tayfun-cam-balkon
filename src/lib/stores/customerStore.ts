import type { Customer } from '#lib/types/models';
import { createRecordStore, text } from './records';

const base = createRecordStore<Customer>(
	'customer',
	'c',
	(key, d, updatedAt) => ({
		id: key,
		name: text(d.name),
		phone: text(d.phone),
		email: text(d.email),
		address: text(d.address),
		city: text(d.city),
		notes: text(d.notes),
		createdAt: text(d.created_at || updatedAt),
		updatedAt
	}),
	(c) => ({
		name: text(c.name).trim(),
		phone: text(c.phone),
		email: text(c.email),
		address: text(c.address),
		city: text(c.city),
		notes: text(c.notes)
	})
);

export const customerStore = {
	subscribe: base.subscribe,
	loadAll: base.loadAll,
	addCustomer: base.add,
	updateCustomer: base.update,
	deleteCustomer: base.remove
};
