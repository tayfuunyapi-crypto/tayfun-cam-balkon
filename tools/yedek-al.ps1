# Bütün kayıtları tarihli bir yedek dosyasına (ZIP içinde JSON) yazar.
# Zamanlanmış görev haftada bir çalıştırır; Başlat menüsündeki "Simdi Yedek Al" ile elle de çalışır.

param([switch]$Bekle)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'yedek-ortak.ps1')

try {
	$erisim = Ac-Oturum
	$yedek = [ordered]@{
		olusturulma = (Get-Date).ToString('o')
		kaynak = $SupabaseUrl
		tablolar = [ordered]@{}
	}
	$ozet = @()
	foreach ($tablo in $YedekTablolari) {
		$satirlar = Oku-Tablo $tablo $erisim
		$yedek.tablolar[$tablo] = $satirlar
		$ozet += "$tablo=$($satirlar.Count)"
	}

	if ($yedek.tablolar['cb_records'].Count -eq 0) {
		throw 'cb_records bos geldi; giris bilgisi veya yetki sorunu olabilir. Yedek yazilmadi.'
	}

	New-Item -ItemType Directory -Force $YedekKlasoru | Out-Null
	$ad = 'yedek-{0:yyyy-MM-dd_HHmm}' -f (Get-Date)
	$json = Join-Path $env:TEMP "$ad.json"
	$zip = Join-Path $YedekKlasoru "$ad.zip"
	[IO.File]::WriteAllText($json, ($yedek | ConvertTo-Json -Depth 100 -Compress), (New-Object Text.UTF8Encoding $false))
	Compress-Archive -Path $json -DestinationPath $zip -Force
	Remove-Item $json -Force

	# Eski yedekleri temizle: en yeni N tanesi kalır
	Get-ChildItem $YedekKlasoru -Filter 'yedek-*.zip' | Sort-Object Name -Descending |
		Select-Object -Skip $SaklanacakYedekSayisi | Remove-Item -Force

	Yaz-Gunluk "Yedek alindi: $zip ($($ozet -join ', '))"
}
catch {
	Yaz-Gunluk "HATA: $($_.Exception.Message)"
	if ($Bekle) { Read-Host 'Kapatmak icin Enter' | Out-Null }
	exit 1
}

if ($Bekle) { Read-Host 'Kapatmak icin Enter' | Out-Null }
