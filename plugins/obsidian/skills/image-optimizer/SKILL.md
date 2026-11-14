---
name: image-optimizer
description: Optimizar el multimedia de un vault de Obsidian — recomprimir imágenes webp estáticas sin pérdida visible (cwebp) y convertir screencasts webp animados a MP4 (ffmpeg) actualizando las referencias en las notas. Úsala cuando el usuario quiera reducir el peso del vault, optimizar/comprimir imágenes, liberar espacio antes de un push a GitHub, o mencione que sus capturas o grabaciones .webp pesan demasiado.
---

# Optimizador de imágenes y screencasts webp

Dos problemas distintos, dos herramientas distintas. **Identifica primero de qué tipo es cada webp** — equivocarse destruye contenido:

| Tipo | Cómo se detecta | Herramienta | Resultado |
|---|---|---|---|
| **webp estático** (captura, imagen) | `webpmux -info` → `Number of frames: 1` o formato VP8 | `cwebp` | Mismo archivo, más ligero, mismo nombre |
| **webp animado** (screencast, grabación) | `webpmux -info` → `Number of frames: >1` | `ffmpeg` → MP4 | `.mp4` nuevo + referencias en notas actualizadas |

⚠️ **Nunca conviertas un webp animado a imagen estática** ni lo pases por `cwebp` (fallará, y si lo "arreglas" con ffmpeg a webp estático, tiras 683 frames de una grabación). **Nunca re-codifiques un animado con `ffmpeg -c:v libwebp`**: el codificador animado de ffmpeg no usa compresión delta y puede **multiplicar el tamaño por 8** (probado: 3,6 MB → 31 MB). La única reducción real de un animado es MP4 (H.264).

## Dependencias

Los binarios no viven en el plugin (son del sistema). Resuélvelos en este orden: PATH del sistema → `%USERPROFILE%\Tools\` → instala si faltan:

- **cwebp / webpmux** (paquete `libwebp` de Google): descarga `libwebp-*-windows-x64.zip` desde `https://storage.googleapis.com/downloads.webmproject.org/releases/webp/` (última versión), extrae y copia `bin\cwebp.exe` y `bin\webpmux.exe` a `%USERPROFILE%\Tools\`.
- **ffmpeg**: comprueba `Get-Command ffmpeg`; en este equipo hay uno en `%APPDATA%\N-Studio\Plugins\ffmpeg.exe` (los scripts ya lo buscan ahí).

## Scripts incluidos

Ambos viven en `scripts/` junto a este SKILL.md y son autocontenidos (auto-detectan binarios, reportan tabla de ahorro).

### 1. Estáticos — `optimize-static-images.ps1`

Recomprime cada webp estático a calidad 80 (`-sharp_yuv`) y **reemplaza el original solo si el resultado es menor**. Ignora los animados (cwebp los rechaza y el script lo reporta sin abortar).

```powershell
# Informe sin tocar nada (SIEMPRE primero):
powershell -ExecutionPolicy Bypass -File <skill>\scripts\optimize-static-images.ps1 -Root "P:\.obsidian\sebastian\assets" -DryRun
# Real:
powershell -ExecutionPolicy Bypass -File <skill>\scripts\optimize-static-images.ps1 -Root "P:\.obsidian\sebastian\assets"
# Más compresión: -Quality 75
```

### 2. Animados — `convert-webp-to-mp4.ps1`

Detecta los webp con >1 frame, los convierte a MP4 (H.264, CRF 23, dimensiones pares, `+faststart`), **actualiza las referencias `nombre.webp` → `nombre.mp4` en todas las notas .md del vault** y mueve los originales a un respaldo FUERA del vault (`%USERPROFILE%\Tools\webp-backup-<timestamp>\`).

```powershell
powershell -ExecutionPolicy Bypass -File <skill>\scripts\convert-webp-to-mp4.ps1 -Vault "P:\.obsidian"
# Otros parámetros: -Crf 20 (más calidad) · -Crf 26 (más ahorro) · -DeleteOriginals (sin respaldo)
```

Tras la conversión, dile al usuario que **verifique en Obsidian** que los screencasts se reproducen bien antes de borrar el respaldo. Aviso honesto que debes dar siempre: en el editor, la animación en línea se vuelve un reproductor de vídeo con controles — cambio de experiencia, no solo de formato.

## Flujo recomendado

1. `webpmux -info` (o el paso 1 del flujo del script) para clasificar estáticos vs animados.
2. DryRun del script correspondiente → enseña el informe de ahorro al usuario.
3. Ejecución real.
4. Verificación: cero referencias `.webp` huérfanas (`grep -rl "\.webp" <vault> --include="*.md"` debe devolver vacío si todos eran animados).
5. Recuerda al usuario el punto de git: los archivos antiguos quedan **en el historial**; si el repo es nuevo, conviene rehacer el commit inicial tras optimizar, para no arrastrar los pesos viejos para siempre.

## Límites y avisos

- Calidad 80 en estáticos y CRF 23 en vídeo son puntos de partida con pérdida **visualmente imperceptible**, pero son lossy: dilo siempre antes de ejecutar.
- No proceses nada por debajo de ~100 KB (el script estático ya lo salta).
- Archivos individuales >100 MB no se pueden subir a GitHub sin LFS; si el objetivo es el push, ese es el umbral que importa, no el total del repo (admitido hasta ~5 GB).
