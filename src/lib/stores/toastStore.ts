import { writable } from 'svelte/store';

export interface ToastItem {
	id: number;
	type: 'success' | 'error' | 'warning' | 'info';
	title: string;
	message: string;
}

const store = writable<ToastItem[]>([]);
let nextId = 1;

function removeToast(id: number) {
	store.update((items) => items.filter((t) => t.id !== id));
}

function addToast(toast: Omit<ToastItem, 'id'>, duration = 4000) {
	const id = nextId++;
	store.update((items) => [...items, { ...toast, id }]);
	setTimeout(() => removeToast(id), duration);
}

export const toastStore = { subscribe: store.subscribe, addToast, removeToast };
