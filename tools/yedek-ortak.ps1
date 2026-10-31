# Yedek betiklerinin ortak ayarları ve Supabase oturum açma yardımcısı.
# Doğrudan çalıştırılmaz; yedek-al / yedek-kur / yedek-geri-yukle tarafından yüklenir.

$SupabaseUrl = 'https://rphczgyzyptpuanturcc.supabase.co'
# Herkese açık (publishable) anahtar: sitenin tarayıcıya gönderdiği anahtarla aynı, gizli değil
$SupabaseAnonKey = 'sb_publishable_HsxEtSEhfQc033m1ExH4Lw_TIDrBqrl'

$AyarKlasoru = Join-Path $env:APPDATA 'TayfunCamBalkon'
$GirisDosyasi = Join-Path $AyarKlasoru 'yedek-giris.xml'
$GunlukDosyasi = Join-Path $AyarKlasoru 'yedek-gunluk.txt'

$onedrive = if ($env:OneDrive) { $env:OneDrive } else { [Environment]::GetFolderPath('MyDocuments') }
$YedekKlasoru = Join-Path $onedrive 'Tayfun Cam Balkon Yedekleri'

# Yedeklenen tablolar; cb_records silinmiş kayıtlar dahil alınır
$YedekTablolari = @('cb_records', 'app_state', 'montaj_takimi', 'montaj_isci', 'montaj_malzeme', 'muteahhit_sozlesme', 'montaj_raporlari')
$SaklanacakYedekSayisi = 52

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Yaz-Gunluk([string]$mesaj) {
	New-Item -ItemType Directory -Force $AyarKlasoru | Out-Null
	$satir = '{0:yyyy-MM-dd HH:mm:ss}  {1}' -f (Get-Date), $mesaj
	Add-Content -Path $GunlukDosyasi -Value $satir -Encoding UTF8
	Write-Host $satir
}

# Kayıtlı (Windows DPAPI ile şifreli) giriş bilgisiyle Supabase oturumu açar, erişim anahtarını döndürür
function Ac-Oturum {
	if (-not (Test-Path $GirisDosyasi)) {
		throw "Giris bilgisi bulunamadi. Once 'Yedeklemeyi Kur' kisayolunu calistirin."
	}
	$giris = Import-Clixml $GirisDosyasi
	$govde = @{ email = $giris.UserName; password = $giris.GetNetworkCredential().Password } | ConvertTo-Json
	$yanit = Invoke-RestMethod "$SupabaseUrl/auth/v1/token?grant_type=password" -Method Post `
		-Headers @{ apikey = $SupabaseAnonKey } -ContentType 'application/json' -Body $govde
	return $yanit.access_token
}

function Al-Basliklar([string]$erisim) {
	return @{ apikey = $SupabaseAnonKey; Authorization = "Bearer $erisim" }
}

# Bir tablonun bütün satırlarını 1000'erli sayfalar hâlinde çeker
function Oku-Tablo([string]$tablo, [string]$erisim) {
	$satirlar = @()
	$baslangic = 0
	$sayfa = 1000
	do {
		# Windows PowerShell 5.1 'Range' başlığına izin vermez; limit/offset kullanılır
		$parca = Invoke-RestMethod "$SupabaseUrl/rest/v1/$tablo`?select=*&limit=$sayfa&offset=$baslangic" -Headers (Al-Basliklar $erisim)
		# Boş yanıt PowerShell'de $null gelir; tek elemanlı dizi saymamak için ayıkla
		$parca = @($parca | Where-Object { $null -ne $_ })
		$satirlar += $parca
		$baslangic += $sayfa
	} while ($parca.Count -eq $sayfa)
	return ,$satirlar
}
