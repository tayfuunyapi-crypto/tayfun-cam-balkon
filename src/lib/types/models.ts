// Tablo sayfalarının (customers-table, projects-table, teklif-table, reports) kullandığı düz modeller.
// Hepsi cb_records satırından üretilir: id = key, alanlar data içinden okunur.
import type { ProjectStatus } from '#lib/workflow';

export type { ProjectStatus };

export interface Customer {
	id: string;
	name: string;
	phone: string;
	email: string;
	address: string;
	city: string;
	notes: string;
	createdAt: string;
	updatedAt: string;
}

export interface Project {
	id: string;
	name: string;
	customer: string;
	description: string;
	status: ProjectStatus;
	// data.price: masaüstü/mobil ve sihirbazla aynı alan
	budget: number;
	timeline: number;
	notes: string;
	createdAt: string;
	updatedAt: string;
}

export type QuoteStatus = 'draft' | 'sent' | 'accepted' | 'rejected' | 'expired';

export interface Quote {
	id: string;
	quoteNumber: string;
	customerName: string;
	amount: number;
	tax: number;
	total: number;
	description: string;
	notes: string;
	status: QuoteStatus;
	validUntil: string;
	createdAt: string;
	updatedAt: string;
}
