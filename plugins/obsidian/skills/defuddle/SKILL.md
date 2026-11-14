---
name: defuddle
description: Extraer Markdown limpio de páginas HTML con la CLI de Defuddle. Úsala cuando el usuario quiera extraer el contenido de una web en Markdown sin publicidad, navegación ni ruido.
---

# Defuddle

Usa la CLI de Defuddle cuando el usuario quiera extraer Markdown limpio de una página web. Elimina la navegación, la publicidad y demás ruido de la página.

Comprueba la disponibilidad resolviendo el binario de forma relativa a este archivo de skill: la raíz del plugin está dos niveles por encima del directorio de esta skill (`skills/defuddle/` → raíz del plugin), y el binario vive en `<raíz-plugin>/node_modules/.bin/defuddle`. En Windows el ejecutable es `<raíz-plugin>\node_modules\.bin\defuddle.cmd`. Si falta `node_modules/` en la raíz del plugin, ofrece instalar con `cd <raíz-plugin> && pnpm install` (las dependencias están declaradas en el `package.json` del propio plugin). Nunca uses un `defuddle` suelto del PATH, `npm install -g` ni `npx`: este plugin mantiene sus dependencias enjauladas dentro de su propio directorio. No afirmes que la extracción tuvo éxito si la herramienta no está disponible o devuelve un error.

## Uso

Usa siempre `--md` para salida en Markdown:

```bash
defuddle parse <url> --md
```

Guardar en archivo:

```bash
defuddle parse <url> --md -o contenido.md
```

Extraer metadatos concretos:

```bash
defuddle parse <url> -p title
defuddle parse <url> -p description
defuddle parse <url> -p domain
```

## Formatos de salida

| Flag | Formato |
|------|--------|
| `--md` | Markdown (elección por defecto) |
| `--json` | JSON con HTML y markdown |
| (ninguno) | HTML |
| `-p <name>` | Propiedad de metadatos concreta |
