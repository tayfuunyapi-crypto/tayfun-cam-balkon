# Tayfun Cam Balkon - Deployment Status

## Yayın

- **Vercel projesi**: `tayfun-cam-balkon` (`prj_ToioNFlkoXtN6VEpAN3OEb47aA69`)
- **GitHub**: `tayfuunyapi-crypto/tayfun-cam-balkon`, Vercel'e bağlı
- `main` dalına her `git push` canlı yayını otomatik günceller; ayrı bir bilgisayara veya CLI'ya gerek yok
- Framework: SvelteKit, adapter: `@sveltejs/adapter-vercel`, Node 24.x

## Ortam değişkenleri (Vercel)

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

Yerel geliştirme için aynı ikisi `.env.local` dosyasına yazılır (Git'e girmez).
Eski `APP_ADMIN_EMAIL`, `APP_ADMIN_PASSWORD`, `APP_SESSION_SECRET` artık kullanılmıyor.

## Giriş

- Giriş Supabase Auth ile yapılır (masaüstü ve mobil uygulamayla aynı hesap)
- Şifre unutulursa giriş ekranındaki "Şifremi unuttum" bağlantısı kullanılır
- Veri erişimi Supabase RLS ile korunur: `cb_records` yalnızca giriş yapmış kullanıcıya açıktır
- Şifre sıfırlama bağlantısının canlı sitede çalışması için Supabase → Authentication → URL Configuration
  altında site adresinin `/auth/reset` yolu izinli olmalıdır

## Yerel geliştirme

```bash
npm install
npm run dev
```

**Son güncelleme**: 2026-11-01
