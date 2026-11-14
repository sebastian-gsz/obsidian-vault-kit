# obsidian-vault-kit

Plugin para trabajar con vaults locales de Obsidian. Deriva del plugin `obsidian` v0.1.2 del marketplace oficial (a su vez derivado de kepano/obsidian-skills y axtonliu/axton-obsidian-visual-skills), reelaborado para ser autocontenido y agnóstico respecto a las dependencias.

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

## Cambios frente a upstream 0.1.2

El historial completo de cambios vive en [CHANGELOG.md](CHANGELOG.md). Resumen: skills `obsidian-headless` y `setup` adaptadas a pnpm; eliminadas `mermaid-visualizer` y `excalidraw-diagram`; documentación traducida al español; skills de autoría `sebastian-vault-writing` y `sebastian-definitions-writing`; `image-optimizer` (1.2.0) y `code-block-fixer` (1.3.0).
