import type { Quote, QuoteStatus } from '#lib/types/models';
import { createRecordStore, num, text } from './records';

// Not: cb_records_kind_check kısıtı 'quote' kabul etmiyor; kısıt güncellenene kadar kayıt hata verir.
const STATUSES: QuoteStatus[] = ['draft', 'sent', 'accepted', 'rejected', 'expired'];

const base = createRecordStore<Quote>(
	'quote',
	'q',
	(key, d, updatedAt) => ({
		id: key,
		quoteNumber: text(d.quoteNumber),
		customerName: text(d.customerName),
		amount: num(d.amount),
		tax: num(d.tax),
		total: num(d.total),
		description: text(d.description),
		notes: text(d.notes),
		status: STATUSES.includes(d.status) ? d.status : 'draft',
		validUntil: text(d.validUntil),
		createdAt: text(d.created_at || updatedAt),
		updatedAt
	}),
	(q) => ({
		quoteNumber: text(q.quoteNumber).trim(),
		customerName: text(q.customerName).trim(),
		amount: num(q.amount),
		tax: num(q.tax),
		total: num(q.total),
		description: text(q.description),
		notes: text(q.notes),
		status: q.status ?? 'draft',
		validUntil: text(q.validUntil)
	})
);

export const quoteStore = {
	subscribe: base.subscribe,
	loadAll: base.loadAll,
	addQuote: base.add,
	updateQuote: base.update,
	deleteQuote: base.remove
};
