# optimize-static-images.ps1 — Recomprime imágenes webp ESTÁTICAS una a una (cwebp, calidad 80),
# reemplazando el original solo si la versión optimizada es más pequeña.
# Los webp animados se reportan y se omiten (para esos existe convert-webp-to-mp4.ps1).
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File optimize-static-images.ps1                       # real
#   powershell -ExecutionPolicy Bypass -File optimize-static-images.ps1 -DryRun               # informe, no toca nada
#   ... -Root "P:\.obsidian\sebastian\assets" -Quality 75

param(
    [string]$Root    = "P:\.obsidian\sebastian\assets",
    [int]   $Quality = 80,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Resolve-Tool {
    param([string]$Name)   # "cwebp" | "webpmux"
    $hit = Get-Command $Name -ErrorAction SilentlyContinue
    if ($hit) { return $hit.Source }
    $local = Join-Path $env:USERPROFILE "Tools\$Name.exe"
    if (Test-Path $local) { return $local }
    throw "No se encuentra $Name.exe. Descarga el paquete libwebp de https://storage.googleapis.com/downloads.webmproject.org/releases/webp/ y copia bin\$Name.exe a %USERPROFILE%\Tools\"
}

$cwebp = Resolve-Tool "cwebp"

if (-not (Test-Path $Root)) { throw "No existe la carpeta $Root" }

$files = Get-ChildItem $Root -Recurse -File -Filter *.webp
Write-Host "Encontrados $($files.Count) archivos .webp en $Root" -ForegroundColor Cyan
if ($DryRun) { Write-Host "MODO PRUEBA: no se modificara ningun archivo`n" -ForegroundColor Yellow }

$results = [System.Collections.Generic.List[object]]::new()
$skipped = 0
$i = 0
$tmp = Join-Path $env:TEMP "cwebp-opt-$PID.webp"

foreach ($f in $files) {
    $i++
    if ($f.Length -lt 100KB) { continue }   # no vale la pena tocar imagenes minusculas
    $before = $f.Length
    # via cmd para que el stderr de cwebp (webp animados no soportados) no aborte el script
    cmd /c "`"$cwebp`" -quiet -q $Quality -sharp_yuv `"$($f.FullName)`" -o `"$tmp`" 2>nul"
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $tmp)) {
        Write-Host "[$i/$($files.Count)] omitido (animado o ilegible): $($f.Name)" -ForegroundColor DarkGray
        $skipped++
        continue
    }
    $after = (Get-Item $tmp).Length
    if ($after -lt $before) {
        $results.Add([pscustomobject]@{
            Archivo      = $f.Name
            'Antes(MB)'  = [math]::Round($before/1MB, 2)
            'Despues(MB)' = [math]::Round($after/1MB, 2)
            'Ahorro(%)'  = [math]::Round(100 * ($before - $after) / $before, 0)
        })
        if (-not $DryRun) { Copy-Item $tmp $f.FullName -Force }
    }
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
}

Write-Host "`n=== RESULTADO ===" -ForegroundColor Cyan
$results | Sort-Object 'Ahorro(%)' -Descending | Format-Table -AutoSize

$totB = ($results | Measure-Object 'Antes(MB)' -Sum).Sum
$totA = ($results | Measure-Object 'Despues(MB)' -Sum).Sum
if ($totB) {
    Write-Host ("{0} imagenes optimizables de {1} escaneadas ({2} omitidas: animadas/minusculas)" -f $results.Count, $files.Count, $skipped)
    Write-Host ("Total: {0} MB -> {1} MB  (ahorro {2} MB, {3}%)" -f `
        [math]::Round($totB,1), [math]::Round($totA,1), `
        [math]::Round($totB-$totA,1), [math]::Round(100*($totB-$totA)/$totB,0))
    if ($DryRun) { Write-Host "(MODO PRUEBA: nada se ha modificado)" -ForegroundColor Yellow }
}
