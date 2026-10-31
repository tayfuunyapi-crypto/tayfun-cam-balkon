# Haftalık otomatik yedeklemeyi kurar:
#  1. Uygulama giriş bilgisini sorar ve Windows'un şifrelemesiyle (DPAPI) yalnızca bu kullanıcıya özel saklar
#  2. Her pazar 12:00'de çalışan zamanlanmış görevi oluşturur (kaçırılırsa bilgisayar açılınca çalışır)
#  3. İlk yedeği hemen alır

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'yedek-ortak.ps1')
$Host.UI.RawUI.WindowTitle = 'Tayfun Cam Balkon - Yedekleme kurulumu'

Write-Host ''
Write-Host 'Tayfun Cam Balkon haftalik yedekleme kurulumu' -ForegroundColor Cyan
Write-Host 'Uygulamaya giris yaptiginiz e-posta ve sifreyi girin. Sifre bu bilgisayarda sifreli saklanir.'
Write-Host ''

$giris = Get-Credential -Message 'Tayfun Cam Balkon giris bilgileri' -UserName 'tayfuunyapi@gmail.com'
if (-not $giris) { Write-Host 'Iptal edildi.'; Read-Host 'Kapatmak icin Enter' | Out-Null; exit 1 }

New-Item -ItemType Directory -Force $AyarKlasoru | Out-Null
$giris | Export-Clixml $GirisDosyasi

try {
	Ac-Oturum | Out-Null
	Write-Host 'Giris basarili.' -ForegroundColor Green
}
catch {
	Remove-Item $GirisDosyasi -Force
	Write-Host "Giris basarisiz: $($_.Exception.Message)" -ForegroundColor Red
	Write-Host 'E-posta veya sifreyi kontrol edip tekrar deneyin.'
	Read-Host 'Kapatmak icin Enter' | Out-Null
	exit 1
}

$betik = Join-Path $PSScriptRoot 'yedek-al.ps1'
$eylem = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
	-Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$betik`""
$tetik = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 12:00
$ayar = New-ScheduledTaskSettingsSet -StartWhenAvailable -RunOnlyIfNetworkAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName 'Tayfun Cam Balkon Yedek' -Action $eylem -Trigger $tetik -Settings $ayar `
	-Description 'Tayfun Cam Balkon verilerini haftalik OneDrive klasorune yedekler' -Force | Out-Null
Write-Host 'Haftalik gorev kuruldu (her pazar 12:00).' -ForegroundColor Green

Write-Host 'Ilk yedek aliniyor...'
& $betik
Write-Host ''
Write-Host "Yedekler: $YedekKlasoru" -ForegroundColor Cyan
Read-Host 'Kapatmak icin Enter' | Out-Null
