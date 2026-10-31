# Yerel geliştirme sunucusunu başlatır ve uygulamayı tarayıcıda açar.
# Masaüstündeki "Tayfun Cam Balkon (Geliştirme)" kısayolu bu dosyayı çalıştırır.

$ErrorActionPreference = 'Stop'
$proje = Split-Path -Parent $PSScriptRoot
$adres = 'http://localhost:5173'
$env:Path = "$env:ProgramFiles\nodejs;$env:ProgramFiles\Git\cmd;$env:Path"

Set-Location $proje
$Host.UI.RawUI.WindowTitle = 'Tayfun Cam Balkon - Gelistirme sunucusu'

if (-not (Test-Path (Join-Path $proje '.env.local'))) {
	Write-Host '.env.local bulunamadi. Supabase ayarlari olmadan uygulama veri gosteremez.' -ForegroundColor Yellow
}

if (-not (Test-Path (Join-Path $proje 'node_modules'))) {
	Write-Host 'Paketler yukleniyor (ilk calistirma)...'
	npm install --no-fund --no-audit
}

$calisiyor = Get-NetTCPConnection -LocalPort 5173 -State Listen -ErrorAction SilentlyContinue
if ($calisiyor) {
	Write-Host 'Sunucu zaten calisiyor, tarayici aciliyor.'
	Start-Process $adres
	Start-Sleep 2
	exit
}

# Sunucu hazır olunca tarayıcıyı aç
Start-Job -ScriptBlock {
	param($url)
	for ($i = 0; $i -lt 60; $i++) {
		try { Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 2 | Out-Null; Start-Process $url; return } catch { Start-Sleep 1 }
	}
} -ArgumentList $adres | Out-Null

Write-Host 'Gelistirme sunucusu baslatiliyor. Kapatmak icin bu pencereyi kapatin.' -ForegroundColor Green
npm run dev -- --port 5173 --strictPort
