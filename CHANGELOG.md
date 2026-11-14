# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).
La fuente de verdad de la versión es `plugins/obsidian/plugin.json`, gestionada
con `scripts/bump.sh`.

## [Sin publicar]

- **Añadido:** `LICENSE` (MIT), `CONTRIBUTING.md`, este changelog, `.gitignore` raíz y `SECURITY.md`.
- **Añadido:** CI que valida manifests (JSON + consistencia de versiones) y el frontmatter de cada `SKILL.md`.
- **Limpiado:** marcas de terceros fuera de los archivos estructurales; el README ya no narra el changelog inline (apunta aquí).

## [1.3.0]

- **Añadido:** skill `code-block-fixer` — reparación de notas con código pegado línea a línea como inline (`` ``línea`` `` / **``línea``**): agrupación en fences ```python con indentación preservada, separación semántica de ejemplos (def/class), y normalización de tabs del indent relativo. Scripts ESM autocontenidos; probado sobre programmiersprachen-python.md (320 chunks → 49 fences).

## [1.2.0]

- **Añadido:** skill `image-optimizer` — recompresión de webp estáticos con cwebp y conversión de screencasts webp animados a MP4 con ffmpeg (actualización automática de referencias en las notas y respaldo de originales fuera del vault). Requiere `cwebp`/`webpmux` (libwebp) y `ffmpeg` en el sistema; los scripts los auto-detectan.

## [1.0.0]

- **Deriva** del plugin `obsidian` v0.1.2 del marketplace oficial (a su vez derivado de kepano/obsidian-skills y axtonliu/axton-obsidian-visual-skills), reelaborado para ser autocontenido y agnóstico respecto a las dependencias.
- **Añadido:** la skill `obsidian-headless` (de obsidianmd/obsidian-skills 1.2.0) y una skill `setup` reescrita y adaptada a pnpm (la original asumía `npm install -g`).
- **Eliminado:** las skills `mermaid-visualizer` y `excalidraw-diagram`; el manifest duplicado interno; las referencias muertas de `bump.sh` a las rutas inexistentes `.claude-plugin/` y `.cursor-plugin/`.
- **Modificado:** los párrafos de disponibilidad/instalación de `defuddle` y `knap` (binarios enjaulados relativos al plugin); `plugin.json` reescrito.
- **Traducido:** toda la documentación y skills al español (código, comandos e identificadores intactos).
- **Añadido:** skills de autoría `sebastian-vault-writing` y `sebastian-definitions-writing` integradas como parte del plugin; esta última exige el plugin comunitario [Note Definitions](https://community.obsidian.md/plugins/note-definitions) en el vault (sección §0 de la skill).
