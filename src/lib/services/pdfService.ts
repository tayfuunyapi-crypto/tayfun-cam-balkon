import type { Customer, Project, Quote } from '#lib/types/models';
import { formatMoney, statusInfo } from '#lib/workflow';

const esc = (value: unknown) =>
	String(value ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[c]!);

const date = (value: string) => (value ? new Date(value).toLocaleDateString('tr-TR') : '-');

function page(title: string, body: string) {
	return `
    <div style="text-align:center;margin-bottom:24px;border-bottom:3px solid #10b981;padding-bottom:16px;">
      <h1 style="color:#10b981;margin:0;">Tayfun Yapı</h1>
      <p style="margin:6px 0 0;color:#6b7280;">${esc(title)} • ${new Date().toLocaleDateString('tr-TR')}</p>
    </div>
    ${body}
    <p style="margin-top:32px;font-size:11px;color:#999;text-align:center;">Tayfun Yapı Cam Balkon Sistemleri • Edremit, Balıkesir</p>`;
}

function table(headers: string[], rows: unknown[][]) {
	const th = headers.map((h) => `<th style="text-align:left;padding:6px;border-bottom:2px solid #e5e7eb;">${esc(h)}</th>`).join('');
	const tr = rows
		.map((r) => `<tr>${r.map((c) => `<td style="padding:6px;border-bottom:1px solid #f0f0f0;">${esc(c)}</td>`).join('')}</tr>`)
		.join('');
	return `<table style="width:100%;border-collapse:collapse;font-size:12px;"><thead><tr>${th}</tr></thead><tbody>${tr}</tbody></table>`;
}

async function save(html: string, filename: string) {
	const element = document.createElement('div');
	element.style.padding = '20px';
	element.style.fontFamily = 'Arial, sans-serif';
	element.innerHTML = html;
	// html2pdf tarayıcı nesnelerine ihtiyaç duyar; sunucuda yüklenirse sayfa 500 verir
	const { default: html2pdf } = await import('html2pdf.js');
	await html2pdf()
		.set({
			margin: [10, 10, 10, 10],
			filename,
			image: { type: 'jpeg', quality: 0.98 },
			html2canvas: { scale: 2 },
			jsPDF: { orientation: 'portrait', unit: 'mm', format: 'a4' }
		})
		.from(element)
		.save();
}

export function exportCustomerListPDF(customers: Customer[]) {
	const rows = customers.map((c) => [c.name, c.phone, c.email, c.city, c.address]);
	return save(
		page(`Müşteri Listesi (${customers.length})`, table(['Ad / Firma', 'Telefon', 'E-posta', 'Şehir', 'Adres'], rows)),
		`musteriler-${Date.now()}.pdf`
	);
}

export function exportProjectReportPDF(project: Project) {
	const rows = [
		['Proje', project.name],
		['Müşteri', project.customer || '-'],
		['Durum', statusInfo(project.status).label],
		['Tutar', formatMoney(project.budget)],
		['Süre (gün)', project.timeline || '-'],
		['Oluşturma', date(project.createdAt)],
		['Açıklama', project.description || '-'],
		['Notlar', project.notes || '-']
	];
	return save(page('Proje Raporu', table(['Alan', 'Değer'], rows)), `proje-${project.id}.pdf`);
}

export function exportQuotePDF(quote: Quote) {
	const rows = [
		['Teklif No', quote.quoteNumber],
		['Müşteri', quote.customerName],
		['Tutar', formatMoney(quote.amount)],
		['KDV', formatMoney(quote.tax)],
		['Toplam', formatMoney(quote.total)],
		['Vade Tarihi', date(quote.validUntil)],
		['Açıklama', quote.description || '-'],
		['Notlar', quote.notes || '-']
	];
	return save(page('Teklif', table(['Alan', 'Değer'], rows)), `teklif-${quote.quoteNumber || quote.id}.pdf`);
}
