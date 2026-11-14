---
name: knap
description: Renderizar Markdown desde plantillas y datos estructurados con la CLI de Knap. Úsala cuando el usuario pida aplicar una plantilla Knap, convertir datos JSON o CSV en notas, generar Markdown por lotes o formatear la salida de Defuddle en una nota.
---

# Knap

Usa la CLI de Knap para renderizar plantillas Markdown con variables, filtros y lógica.

Comprueba la disponibilidad resolviendo el binario de forma relativa a este archivo de skill: la raíz del plugin está dos niveles por encima del directorio de esta skill (`skills/knap/` → raíz del plugin), y el binario vive en `<raíz-plugin>/node_modules/.bin/knap`. En Windows el ejecutable es `<raíz-plugin>\node_modules\.bin\knap.cmd`. Si falta `node_modules/` en la raíz del plugin, ofrece instalar con `cd <raíz-plugin> && pnpm install` (las dependencias están declaradas en el `package.json` del propio plugin). Knap requiere Node.js 20 o superior. Nunca uses un `knap` suelto del PATH, `npm install -g` ni `npx`: este plugin mantiene sus dependencias enjauladas dentro de su propio directorio. No afirmes que una plantilla fue renderizada si la herramienta no está disponible o devuelve un error.

Ejecuta `knap --help` para ver los comandos y opciones disponibles. Descubre el lenguaje mediante la referencia offline de la CLI:

```bash
knap help syntax
knap help filters
knap help filter date
knap help tags
knap help tag for
```

Usa las listas para encontrar nombres y luego pide ayuda individual de sintaxis, parámetros y ejemplos con salida esperada.

## Uso

Renderizar una plantilla con variables JSON:

```bash
knap render template.md --data article.json -o note.md
```

Proporcionar plantilla y datos en línea:

```bash
knap render -t '# {{ title | trim }}' --data-json '{"title":"Hello"}'
```

Sobrescribir una variable o canalizar datos JSON:

```bash
knap render template.md --data article.json --set 'title=Custom title'
cat article.json | knap render template.md --data -
```

Los datos deben ser un objeto JSON; sus propiedades se convierten en variables de plantilla. `--set` sobrescribe claves literales de primer nivel con strings. Usa JSON para objetos anidados, arrays, números y booleanos.

Elige una fuente de plantilla (archivo, `-t` o stdin) y una fuente de datos (`--data` o `--data-json`). Solo una entrada puede leer de stdin. Sin archivo de plantilla ni `-t`, Knap lee la plantilla de stdin.

La salida va a stdout por defecto. `-o` crea los directorios padre y sobrescribe el destino tras un renderizado correcto. Los errores terminan con estado `1`; los diagnósticos van a stderr. Las advertencias pueden acompañar a una salida correcta.

## Plantillas

Usa `{{ variable }}` para valores, `|` para filtros y `{% ... %}` para lógica. Por ejemplo, guarda esto como `template.md`:

```knap
---
{{ title | yaml_property:"title" }}
{{ tags | yaml_property:"tags" }}
---
# {{ title | trim }}
{% if author %}
By {{ author }}
{% endif %}

{{ content }}
```

Usa `yaml_property` para propiedades completas de frontmatter, así los valores se entrecomillan e indentan correctamente. La CLI incluye los filtros estándar, pero no aporta variables de navegador de Web Clipper, selectores, prompts ni filtros HTML dependientes del DOM. Aporta las variables mediante JSON.

Comprueba una plantilla antes de renderizarla:

```bash
knap validate template.md
```

La validación comprueba sintaxis, nombres de filtros y argumentos estáticos de filtros sin datos ni salida a archivo. No comprueba existencia de variables, valores en tiempo de ejecución ni argumentos dinámicos; renderiza con datos reales para comprobar el comportamiento en ejecución. Los diagnósticos van a stderr e incluyen los comandos de ayuda relevantes.

## Pipeline con Defuddle

Extrae una página web como JSON con contenido en Markdown y renderízala en una nota:

```bash
defuddle parse https://example.com/article --md --json \
  | knap render template.md --data - -o note.md
```

Las propiedades JSON de Defuddle, como `title` y `content`, se convierten directamente en variables de plantilla.

## Renderizado por lotes

Crea un archivo por cada fila CSV, objeto de array JSON o archivo JSON de una carpeta:

```bash
knap batch template.md --data articles.csv --output-dir notas \
  --filename '{{ title | safe_name }}.md'
```

Usa `--data articles.json` para un array o `--data ./articles` para una carpeta de objetos JSON. Las cabeceras CSV se convierten en nombres de variables y los valores permanecen como strings. Los datos canalizados se asumen JSON por defecto; añade `--format csv` para CSV canalizado.

Usa `--dry-run` para validar y listar las rutas de salida sin escribir archivos. Los archivos existentes requieren `--overwrite`, también durante un dry run. Los nombres de salida duplicados dentro de un lote son errores incluso con `--overwrite`.

Las plantillas de nombre de archivo deben producir un único nombre con su extensión, sin directorios. Usa `safe_name` para nombres derivados de los datos. Sin `--filename`, Knap conserva los basenames del JSON de origen o numera las filas CSV y los elementos de arrays como `1.md`, `2.md`, etc.
