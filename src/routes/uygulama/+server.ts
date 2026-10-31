import { redirect } from '@sveltejs/kit';

// Asıl uygulama static/uygulama/index.html (tek dosya, hash yönlendirmeli).
// Klasör adresi her ortamda index.html'e düşmediği için buradan yönlendirilir.
export const GET = () => {
	redirect(307, '/uygulama/index.html');
};
