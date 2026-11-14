# obsidian-vault-kit

Plugin para trabajar con vaults locales de Obsidian. Deriva del plugin `obsidian` v0.1.2 de zcode-plugins-official (a su vez de kepano/obsidian-skills y axtonliu/axton-obsidian-visual-skills), reelaborado para ser autocontenido y agnóstico respecto a las dependencias.

## Instalación

El repo incluye un marketplace local en `.agents/plugins/marketplace.json` que apunta a `./plugins/obsidian`. Regístralo en como marketplace local o instala el plugin directamente desde esa ruta.

## Estructura

```
plugins/obsidian/            ← el plugin
├── plugin.json              ← manifest (obsidian-vault-kit 1.0.0)
├── package.json + pnpm-lock.yaml  ← inventario de dependencias CLI
├── node_modules/            ← binarios enjaulados (defuddle, knap) — gitignored
├── assets/icon.png
└── skills/
    ├── defuddle/            extracción web → Markdown
    ├── json-canvas/         tableros .canvas
    ├── knap/                plantillas → notas
    ├── obsidian-bases/      vistas .base
    ├── obsidian-cli/        vaults vía Obsidian CLI (app en ejecución)
    ├── obsidian-headless/   sync/publish sin la app desktop
    ├── obsidian-markdown/   Obsidian Flavored Markdown
    ├── setup/               verificación de tooling
    ├── image-optimizer/      optimización de imágenes webp y screencasts → MP4
    ├── code-block-fixer/     reparación de código pegado como inline en notas
    ├── sebastian-vault-writing/          escritura de notas del vault
    └── sebastian-definitions-writing/    glosario Note Definitions
.agents/plugins/marketplace.json
scripts/bump.sh              bump de versión del manifest
```

## Dependencias

`defuddle-cli` y `knap` se instalan con **pnpm dentro del propio plugin** (`cd plugins/obsidian && pnpm install`). Las skills resuelven los binarios de forma relativa a la raíz del plugin — nunca `npm install -g` ni `npx`. Borrar el plugin borra todo: cero huérfanos en el prefijo global de npm.

## Requisitos

- Node.js ≥ 20 y pnpm (para los binarios enjaulados). - Obsidian desktop 1.12.7+ con la CLI activada (Settings → General → Command line interface) para la skill `obsidian-cli`; Obsidian Headless (`ob`) para la skill headless.

## Cambios frente a upstream 0.1.2 (empaquetado Z.ai)

- **Añadido:** la skill `obsidian-headless` (de obsidianmd/obsidian-skills 1.2.0) y una skill `setup` reescrita y adaptada a pnpm (la original asumía `npm install -g`).
- **Eliminado:** las skills `mermaid-visualizer` y `excalidraw-diagram`; el manifest duplicado de Z.ai en `.zcode-plugin/`; las referencias muertas de `bump.sh` a las rutas inexistentes `.claude-plugin/` y `.cursor-plugin/`.
- **Modificado:** los párrafos de disponibilidad/instalación de `defuddle` y `knap` (binarios enjaulados relativos al plugin); `plugin.json` reescrito.
- **Traducido:** toda la documentación y skills al español (código, comandos e identificadores intactos).
- **Añadido:** skills de autoría `sebastian-vault-writing` y `sebastian-definitions-writing` integradas como parte del plugin; esta última exige el plugin comunitario [Note Definitions](https://community.obsidian.md/plugins/note-definitions) en el vault (sección §0 de la skill).
- **Añadido (1.2.0):** skill `image-optimizer` — recompresión de webp estáticos con cwebp y conversión de screencasts webp animados a MP4 con ffmpeg (actualización automática de referencias en las notas y respaldo de originales fuera del vault). Requiere `cwebp`/`webpmux` (libwebp) y `ffmpeg` en el sistema; los scripts los auto-detectan.
- **Añadido (1.3.0):** skill `code-block-fixer` — reparación de notas con código pegado línea a línea como inline (`` ``línea`` `` / **``línea``**): agrupación en fences ```python con indentación preservada, separación semántica de ejemplos (def/class), y normalización de tabs del indent relativo. Scripts ESM autocontenidos; probado sobre programmiersprachen-python.md (320 chunks → 49 fences).
