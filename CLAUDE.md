# Tayfun Cam Balkon — Web Uygulaması

Tayfun Yapı'nın cam balkon / zip perde / giyotin işleri için müşteri, iş, çizim, montaj ve teklif
takip uygulaması. Uzun yıllar kullanılacak; değişiklikler küçük, geri alınabilir ve test edilmiş olmalı.
Kullanıcı Türkçe konuşur; arayüz metinleri ve açıklamalar Türkçe yazılır.

## Kısa bakış

- SvelteKit 3 + Svelte 5 (runes), TypeScript, Vite 8, `@sveltejs/adapter-vercel`
- Veri: Supabase projesi `rphczgyzyptpuanturcc`, tek tablo `public.cb_records`
- Yayın: GitHub `tayfuunyapi-crypto/tayfun-cam-balkon` → Vercel; `main`'e her push canlıya çıkar
- Canlı adres: https://tayfun-cam-balkon-cloud-c5d2.vercel.app
- Aynı veritabanını masaüstü ve mobil uygulama da kullanır (`origin`: `desktop` / `mobile` / `web`)

## Komutlar

```bash
npm install
npm run dev      # http://localhost:5173
npm run check    # svelte-check (bilinen eski tip hataları var, yenisini ekleme)
npm run build
```

Yerel ortam için `.env.local` (Git'e girmez): `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`.

## Veri modeli: `cb_records`

Sütunlar: `key` (text), `kind` (text), `data` (jsonb), `origin`, `deleted` (bool), `updated_at`, `updated_by`.
**`created_at` sütunu yok** — sıralamada `updated_at` kullan, tarih gerekiyorsa `data.created_at || updated_at`.

`kind` değerleri: `customer`, `project`, `drawing`, `quote`, `template`, `bundle`, `cut`, `sysedit`, `webapp`.
Silme = `deleted: true` (yumuşak silme); sorgularda `.eq('deleted', false)` unutma.

Çizim (`drawing`) iki şekilde gelir:
- web: `data.props.width/height`, `data.price`, `data.area`
- masaüstü/mobil: `data.segments[]` (width/height), `data.result` (area, sale…), `data.pricing.total`,
  `data.system_code`, `data.pos_no`
Yeni ekranlar ikisini de okumalı (örnek: `src/routes/designs/+page.svelte`).

İş durumları `src/lib/workflow.ts` içinde (`OLCULDU` → `TESLIM`).

## Giriş ve güvenlik

- Giriş Supabase Auth ile tarayıcıda yapılır (`src/lib/stores/auth.ts`); masaüstü/mobil ile aynı hesap.
- RLS: `cb_records` yalnızca `authenticated` rolüne okuma/yazma izni verir; anonim istek boş döner.
- Sayfa koruması istemcide `src/routes/+layout.svelte` içinde; sunucu tarafında oturum yok.
- Şifre sıfırlama: `/auth/login` → "Şifremi unuttum" → `/auth/reset`.
- Service role anahtarı istemciye asla girmez. Ortam değişkeni eklerken SvelteKit 3 kuralı:
  sunucu değişkenleri `src/env.ts` içinde `defineEnvVars` ile tanımlanmalı, `process.env` dev'de boş gelir.

## Kod kuralları

- Supabase'e erişim doğrudan tarayıcıdan, `#lib/supabase` istemcisiyle; proje güncellemeleri için
  `#lib/project-records.ts`.
- Tarayıcıya özgü kütüphaneler (html2pdf vb.) sayfa üstünde import edilmez, kullanıldığı yerde
  `await import(...)` ile yüklenir; aksi halde SSR 500 verir.
- Svelte 5 olay sözdizimi (`onclick`, `onsubmit`); aynı bileşende eski `on:` ile karıştırma (derleme hatası).
- Değişiklikten sonra: `npm run check`, ardından ilgili sayfayı tarayıcıda giriş yapmış hâlde dene.
- Canlıya çıkmadan önce kullanıcıdan onay al; push = canlı yayın.
