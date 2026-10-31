# Masaüstüne ve Başlat menüsüne Tayfun Cam Balkon kısayollarını oluşturur.
# Yeni bir bilgisayarda repoyu klonladıktan sonra bir kez çalıştırmanız yeterli:
#   powershell -ExecutionPolicy Bypass -File tools\kisayollari-olustur.ps1

$ErrorActionPreference = 'Stop'
$proje = Split-Path -Parent $PSScriptRoot
$canliAdres = 'https://tayfun-cam-balkon-cloud-c5d2.vercel.app'

$edge = @(
	"${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
	"$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

$ikon = Join-Path $PSScriptRoot 'tayfun.ico'
$png = Join-Path $proje 'static\logo-192.png'

# Uygulama logosundan (PNG) Windows ikonu üret: tek görüntülü, PNG gömülü ICO
if (-not (Test-Path $ikon) -and (Test-Path $png)) {
	$veri = [IO.File]::ReadAllBytes($png)
	$akis = New-Object IO.MemoryStream
	$y = New-Object IO.BinaryWriter $akis
	$y.Write([UInt16]0); $y.Write([UInt16]1); $y.Write([UInt16]1)
	$y.Write([Byte]192); $y.Write([Byte]192); $y.Write([Byte]0); $y.Write([Byte]0)
	$y.Write([UInt16]1); $y.Write([UInt16]32); $y.Write([UInt32]$veri.Length); $y.Write([UInt32]22)
	$y.Write($veri)
	[IO.File]::WriteAllBytes($ikon, $akis.ToArray())
}

$shell = New-Object -ComObject WScript.Shell

function Yeni-Kisayol($yol, $hedef, $argumanlar, $aciklama, $calismaKlasoru) {
	$k = $shell.CreateShortcut($yol)
	$k.TargetPath = $hedef
	if ($argumanlar) { $k.Arguments = $argumanlar }
	if ($calismaKlasoru) { $k.WorkingDirectory = $calismaKlasoru }
	$k.Description = $aciklama
	if (Test-Path $ikon) { $k.IconLocation = $ikon }
	$k.Save()
}

$masaustu = [Environment]::GetFolderPath('Desktop')
$baslat = Join-Path ([Environment]::GetFolderPath('Programs')) 'Tayfun Cam Balkon'
New-Item -ItemType Directory -Force $baslat | Out-Null

foreach ($klasor in @($masaustu, $baslat)) {
	if ($edge) {
		Yeni-Kisayol (Join-Path $klasor 'Tayfun Cam Balkon.lnk') $edge "--app=$canliAdres" 'Canli uygulamayi acar' $null
	} else {
		Yeni-Kisayol (Join-Path $klasor 'Tayfun Cam Balkon.lnk') $canliAdres $null 'Canli uygulamayi acar' $null
	}
}

Yeni-Kisayol (Join-Path $baslat 'Tayfun Cam Balkon (Gelistirme).lnk') "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
	"-NoLogo -ExecutionPolicy Bypass -File `"$proje\tools\baslat-gelistirme.ps1`"" 'Yerel gelistirme sunucusunu baslatir' $proje
Yeni-Kisayol (Join-Path $baslat 'Proje Klasoru.lnk') "$env:SystemRoot\explorer.exe" "`"$proje`"" 'Proje klasorunu acar' $null

Write-Host "Kisayollar olusturuldu: masaustu ve Baslat menusu > Tayfun Cam Balkon"
