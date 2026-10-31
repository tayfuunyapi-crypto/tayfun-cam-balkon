# Bir yedekten cb_records kayıtlarını geri yükler.
# Örnekler:
#   .\yedek-geri-yukle.ps1 -Yedek '...\yedek-2026-11-02_1200.zip' -Anahtar p-123      # tek kayıt
#   .\yedek-geri-yukle.ps1 -Yedek '...\yedek-2026-11-02_1200.zip' -Hepsi              # bütün kayıtlar
# Var olan kayıtların üzerine yazar (aynı key). Yedekte olmayan yeni kayıtlara dokunmaz.

param(
	[Parameter(Mandatory)][string]$Yedek,
	[string[]]$Anahtar,
	[switch]$Hepsi
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'yedek-ortak.ps1')

if (-not $Hepsi -and -not $Anahtar) { throw '-Anahtar veya -Hepsi belirtin.' }

$gecici = Join-Path $env:TEMP ('tcb-geri-' + [guid]::NewGuid())
Expand-Archive -Path $Yedek -DestinationPath $gecici
$icerik = Get-Content (Get-ChildItem $gecici -Filter '*.json' | Select-Object -First 1).FullName -Raw -Encoding UTF8 | ConvertFrom-Json
Remove-Item $gecici -Recurse -Force

$kayitlar = @($icerik.tablolar.cb_records)
if (-not $Hepsi) { $kayitlar = @($kayitlar | Where-Object { $Anahtar -contains $_.key }) }
if ($kayitlar.Count -eq 0) { throw 'Yedekte eslesen kayit yok.' }

Write-Host "$($kayitlar.Count) kayit geri yuklenecek (yedek tarihi: $($icerik.olusturulma))."
if ((Read-Host 'Devam etmek icin EVET yazin') -ne 'EVET') { Write-Host 'Iptal edildi.'; exit 1 }

$erisim = Ac-Oturum
$basliklar = Al-Basliklar $erisim
$basliklar['Prefer'] = 'resolution=merge-duplicates,return=minimal'

$satirlar = $kayitlar | ForEach-Object {
	[ordered]@{ key = $_.key; kind = $_.kind; data = $_.data; origin = $_.origin; deleted = $_.deleted }
}
for ($i = 0; $i -lt $satirlar.Count; $i += 200) {
	$parca = @($satirlar[$i..([Math]::Min($i + 199, $satirlar.Count - 1))])
	$govde = [Text.Encoding]::UTF8.GetBytes((ConvertTo-Json -InputObject $parca -Depth 100 -Compress))
	Invoke-RestMethod "$SupabaseUrl/rest/v1/cb_records?on_conflict=key" -Method Post -Headers $basliklar `
		-ContentType 'application/json; charset=utf-8' -Body $govde | Out-Null
}
Yaz-Gunluk "Geri yuklendi: $($kayitlar.Count) kayit, kaynak $Yedek"
