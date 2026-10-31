import { writable, derived } from 'svelte/store';
import { supabase } from '../supabase';

type AppUser = {
	id: string;
	email: string;
};

const currentUser = writable<AppUser | null>(null);
export const user = derived(currentUser, ($user) => $user);
export const isAuthenticated = derived(currentUser, ($user) => $user !== null);

function toAppUser(sessionUser: { id: string; email?: string } | null | undefined): AppUser | null {
	return sessionUser ? { id: sessionUser.id, email: sessionUser.email ?? '' } : null;
}

export const auth = {
	session: currentUser,
	user,
	isAuthenticated,
	async initialize() {
		const { data } = await supabase.auth.getSession();
		currentUser.set(toAppUser(data.session?.user));

		const { data: listener } = supabase.auth.onAuthStateChange((_event, session) => {
			currentUser.set(toAppUser(session?.user));
		});

		return () => listener.subscription.unsubscribe();
	},
	async signInWithPassword(email: string, password: string) {
		const { data, error } = await supabase.auth.signInWithPassword({ email: email.trim(), password });

		if (error) {
			throw new Error(
				error.message === 'Invalid login credentials' ? 'E-posta veya şifre hatalı' : error.message
			);
		}
		currentUser.set(toAppUser(data.user));
	},
	async sendPasswordReset(email: string) {
		const { error } = await supabase.auth.resetPasswordForEmail(email.trim(), {
			redirectTo: `${window.location.origin}/auth/reset`
		});
		if (error) throw new Error(error.message);
	},
	async updatePassword(password: string) {
		const { error } = await supabase.auth.updateUser({ password });
		if (error) throw new Error(error.message);
	},
	async signUp() {
		throw new Error('Yeni kullanıcı kaydı yönetici tarafından yapılır');
	},
	async signOut() {
		await supabase.auth.signOut();
		currentUser.set(null);
	}
};
