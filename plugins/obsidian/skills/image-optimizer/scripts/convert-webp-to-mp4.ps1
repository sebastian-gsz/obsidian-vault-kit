# convert-webp-to-mp4.ps1 — Convierte webp ANIMADOS (screencasts) a MP4 dentro de un vault de Obsidian.
# - Solo toca los webp con más de 1 frame (los estáticos no se tocan: siguen siendo imágenes).
# - Guarda el original en carpeta de respaldo FUERA del vault (no borra nada por defecto).
# - Actualiza las referencias en las notas .md del vault:  nombre.webp -> nombre.mp4
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File convert-webp-to-mp4.ps1
#   ... -Vault "P:\.obsidian"        # otro vault (por defecto P:\.obsidian)
#   ... -Crf 20                      # calidad (18=mejor/más pesado, 26=peor/ligero; default 23)
#   ... -DeleteOriginals             # NO respaldar: borrar el webp original tras convertir

param(
    [string]$Vault = "P:\.obsidian",
    [int]   $Crf = 23,
    [switch]$DeleteOriginals
)

$ErrorActionPreference = "Stop"

function Resolve-Tool {
    param([string]$Name)
    $hit = Get-Command $Name -ErrorAction SilentlyContinue
    if ($hit) { return $hit.Source }
    $local = Join-Path $env:USERPROFILE "Tools\$Name.exe"
    if (Test-Path $local) { return $local }
    if ($Name -eq "ffmpeg") {
        $nstudio = Join-Path $env:APPDATA "N-Studio\Plugins\ffmpeg.exe"
        if (Test-Path $nstudio) { return $nstudio }
    }
    throw "No se encuentra $Name.exe. Instalalo y vuelve a ejecutar."
}

$ffmpeg  = Resolve-Tool "ffmpeg"
$webpmux = Resolve-Tool "webpmux"
$BackupDir = Join-Path $env:USERPROFILE ("Tools\webp-backup-" + (Get-Date -Format "yyyyMMdd-HHmmss"))

if (-not (Test-Path $Vault)) { throw "No existe el vault $Vault" }
if (-not $DeleteOriginals) { New-Item $BackupDir -ItemType Directory -Force | Out-Null }

# ---------- 1. Detectar webp animados ----------
$all = Get-ChildItem $Vault -Recurse -File -Filter *.webp |
       Where-Object { $_.FullName -notmatch '\\\.git\\|\\\.trash\\|webp-backup' }
Write-Host "Escaneando $($all.Count) archivos .webp en $Vault ..." -ForegroundColor Cyan

$animated = [System.Collections.Generic.List[object]]::new()
foreach ($f in $all) {
    $info = cmd /c "`"$webpmux`" -info `"$($f.FullName)`" 2>nul"
    $frames = ($info | Select-String "Number of frames:\s+(\d+)").Matches.Groups[1].Value
    if ([int]$frames -gt 1) {
        $animated.Add([pscustomobject]@{ File = $f; Frames = [int]$frames })
    }
}
Write-Host ("Animados: {0} de {1}`n" -f $animated.Count, $all.Count) -ForegroundColor Cyan

# ---------- 2. Convertir cada animado a MP4 ----------
$tmp = Join-Path $env:TEMP "webp2mp4-$PID.mp4"
$done = [System.Collections.Generic.List[object]]::new()

foreach ($item in $animated) {
    $f = $item.File
    Write-Host ("[{0}/{1}] {2}  ({3} frames)..." -f ($done.Count+1), $animated.Count, $f.Name, $item.Frames) -NoNewline
    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    # yuv420p + recorte a dimensiones pares (requisito H.264); faststart para reproducir al instante
    & $ffmpeg -hide_banner -loglevel error -y -i $f.FullName `
        -c:v libx264 -crf $Crf -preset medium -pix_fmt yuv420p `
        -vf "crop=trunc(iw/2)*2:trunc(ih/2)*2" `
        -movflags +faststart -an $tmp

    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $tmp) -or (Get-Item $tmp).Length -eq 0) {
        Write-Host " ERROR" -ForegroundColor Red
        continue
    }

    $mp4 = Join-Path $f.DirectoryName ($f.BaseName + ".mp4")
    Copy-Item $tmp $mp4 -Force
    Remove-Item $tmp -Force

    $before = $f.Length
    $after  = (Get-Item $mp4).Length

    # ---------- 3. Actualizar referencias en notas .md ----------
    $needle = $f.Name                       # "grabacion.webp"
    $replace = $f.BaseName + ".mp4"         # "grabacion.mp4"
    $notesChanged = 0
    Get-ChildItem $Vault -Recurse -File -Filter *.md |
        Where-Object { $_.FullName -notmatch '\\\.git\\|\\\.trash\\|webp-backup' } |
        ForEach-Object {
            $c = Get-Content $_.FullName -Raw -Encoding UTF8
            if ($c -and $c.Contains($needle)) {
                Set-Content $_.FullName ($c.Replace($needle, $replace)) -Encoding UTF8 -NoNewline
                $notesChanged++
            }
        }

    # ---------- 4. Respaldar o borrar el original ----------
    if ($DeleteOriginals) { Remove-Item $f.FullName -Force }
    else                  { Copy-Item $f.FullName $BackupDir -Force; Remove-Item $f.FullName -Force }

    $sw.Stop()
    $done.Add([pscustomobject]@{
        Archivo     = $f.Name
        'WebP(MB)'  = [math]::Round($before/1MB,1)
        'MP4(MB)'   = [math]::Round($after/1MB,1)
        'Ahorro(%)' = [math]::Round(100*($before-$after)/$before,0)
        Notas       = $notesChanged
        Segundos    = [math]::Round($sw.Elapsed.TotalSeconds,0)
    })
    Write-Host (" OK  {0} MB -> {1} MB ({2} notas actualizadas)" -f `
        [math]::Round($before/1MB,1), [math]::Round($after/1MB,1), $notesChanged) -ForegroundColor Green
}

Write-Host "`n=== RESULTADO ===" -ForegroundColor Cyan
$done | Format-Table -AutoSize
$totB = ($done | Measure-Object 'WebP(MB)' -Sum).Sum
$totA = ($done | Measure-Object 'MP4(MB)'  -Sum).Sum
if ($totB) {
    Write-Host ("Total: {0} MB -> {1} MB  (ahorrados {2} MB, {3}%)" -f $totB, $totA, [math]::Round($totB-$totA,1), [math]::Round(100*($totB-$totA)/$totB,0))
}
if (-not $DeleteOriginals -and $done.Count -gt 0) {
    Write-Host ("Originales respaldados en: {0}  (borralos cuando verifiques que todo se ve bien)" -f $BackupDir) -ForegroundColor Yellow
}
