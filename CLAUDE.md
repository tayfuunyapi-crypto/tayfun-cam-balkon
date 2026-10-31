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

## Ana uygulama: `static/uygulama/` (eski "Cam Balkon" uygulaması)

Kullanıcının her gün kullandığı, asıl geliştirilen uygulama budur: tek dosya `static/uygulama/index.html`
(düz HTML/JS, hash rotalar `#/home`, `#/projects`, `#/systems`…), adres `/uygulama/`
(`src/routes/uygulama/+server.ts` → `/uygulama/index.html` yönlendirmesi).
- Eskiden `tayfun-cambalkon.vercel.app` kabuğu bu HTML'i `cb_records` `webapp` kaydından çekiyordu; masaüstü
  "Tayfun Yapı Stüdyo" programı o kaydı güncelliyordu. Artık kaynak bu repodaki dosya; `webapp` kaydına yazılmaz.
- Hâlâ masaüstüne bağlı kısımlar: `bundle` kaydı (sistemler, fiyatlar, Python hesap motoru `src`, montaj listesi)
  ve `sysedit` kuyruğu (fiyat düzenlemeleri, montaj durumu "masaüstüne gönderilecek"). Bunları adım adım
  web tarafına almak sıradaki iş.
- Supabase oturumu SvelteKit sayfalarıyla aynı origin'de paylaşılır (aynı localStorage anahtarı).
- `src/routes` altındaki SvelteKit sayfaları ikinci plandadır; yeni özellikler önce `static/uygulama`ya eklenir.

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

`kind` değerleri: `customer`, `project`, `drawing`, `bundle`, `cut`, `sysedit`, `webapp`.
Veritabanındaki `cb_records_kind_check` kısıtı **`quote` ve `template` kabul etmiyor** — Teklif ve Şablon
sayfaları bu yüzden kayıt yapamıyor; bu özellikler açılmadan önce kısıt güncellenmeli.
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

- Yeni kayıt (sign-up) `auth.users` üzerindeki `enforce_allowed_signup` tetikleyicisiyle `public.allowed_emails`
  listesine bağlı. Montaj tabloları (`montaj_*`, `muteahhit_sozlesme`) yalnızca `authenticated`.
- `share_3d` RPC fonksiyonları bilerek anonim açık (müşteriye 3D paylaşım bağlantısı).

## Yedek

- `tools\yedek-al.ps1`: bütün tabloları `%OneDrive%\Tayfun Cam Balkon Yedekleri\yedek-*.zip` içine yazar, son 52 kalır.
- `tools\yedek-kur.ps1`: giriş bilgisini DPAPI ile `%APPDATA%\TayfunCamBalkon\yedek-giris.xml`'e kaydeder,
  "Tayfun Cam Balkon Yedek" zamanlanmış görevini (pazar 12:00) kurar. Günlük: `%APPDATA%\TayfunCamBalkon\yedek-gunluk.txt`.
- `tools\yedek-geri-yukle.ps1 -Yedek <zip> -Anahtar <key>|-Hepsi`: cb_records kayıtlarını key üzerinden geri yazar.
- Kısayollar: `tools\kisayollari-olustur.ps1` (masaüstü + Başlat menüsü "Tayfun Cam Balkon").

## Kod kuralları

- Supabase'e erişim doğrudan tarayıcıdan, `#lib/supabase` istemcisiyle; proje güncellemeleri için
  `#lib/project-records.ts`.
- Tarayıcıya özgü kütüphaneler (html2pdf vb.) sayfa üstünde import edilmez, kullanıldığı yerde
  `await import(...)` ile yüklenir; aksi halde SSR 500 verir.
- Svelte 5 olay sözdizimi (`onclick`, `onsubmit`); aynı bileşende eski `on:` ile karıştırma (derleme hatası).
- Değişiklikten sonra: `npm run check`, ardından ilgili sayfayı tarayıcıda giriş yapmış hâlde dene.
- Canlıya çıkmadan önce kullanıcıdan onay al; push = canlı yayın.
