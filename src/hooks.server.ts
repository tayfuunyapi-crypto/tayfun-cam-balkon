import { redirect } from '@sveltejs/kit';

// Oturum Supabase Auth ile tarayıcıda tutulur; sayfa koruması +layout.svelte'de,
// veri koruması Supabase RLS ile yapılır.
export const handle = async ({ event, resolve }: { event: any; resolve: any }) => {
	if (event.url.pathname === '/auth/signup') {
		redirect(303, '/auth/login');
	}

	return resolve(event);
};
