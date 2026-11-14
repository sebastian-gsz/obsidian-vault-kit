---
name: json-canvas
description: Crea y edita archivos JSON Canvas (.canvas) con nodos, edges, grupos y conexiones. Úsala cuando trabajes con archivos .canvas, crees canvas visuales, mapas mentales, diagramas de flujo, o cuando el usuario mencione archivos Canvas en Obsidian.
---

# Skill de JSON Canvas

## Estructura del archivo

Un archivo canvas (`.canvas`) contiene dos arrays de nivel superior siguiendo la [JSON Canvas Spec 1.0](https://jsoncanvas.org/spec/1.0/):

```json
{
  "nodes": [],
  "edges": []
}
```

- `nodes` (opcional): Array de objetos de nodo
- `edges` (opcional): Array de objetos edge que conectan nodos

## Flujos de trabajo comunes

### 1. Crear un canvas nuevo

1. Crea un archivo `.canvas` con la estructura base `{"nodes": [], "edges": []}`
2. Genera IDs hexadecimales únicos de 16 caracteres para cada nodo (p. ej., `"6f0ad84f44ce9c17"`)
3. Añade los nodos con los campos obligatorios: `id`, `type`, `x`, `y`, `width`, `height`
4. Añade edges que referencien IDs de nodos válidos mediante `fromNode` y `toNode`
5. **Valida**: Parsea el JSON para confirmar que es válido. Verifica que todos los valores de `fromNode`/`toNode` existan en el array de nodos

### 2. Añadir un nodo a un canvas existente

1. Lee y parsea el archivo `.canvas` existente
2. Genera un ID único que no colisione con los IDs existentes de nodos ni de edges
3. Elige una posición (`x`, `y`) que evite superponerse con nodos existentes (deja un espaciado de 50-100px)
4. Agrega el nuevo objeto de nodo al array `nodes`
5. Opcionalmente, añade edges que conecten el nuevo nodo con los nodos existentes
6. **Valida**: Confirma que todos los IDs sean únicos y que todas las referencias de edges apunten a nodos existentes

### 3. Conectar dos nodos

1. Identifica los IDs de los nodos origen y destino
2. Genera un ID de edge único
3. Establece `fromNode` y `toNode` con los IDs de origen y destino
4. Opcionalmente, establece `fromSide`/`toSide` (top, right, bottom, left) para los puntos de anclaje
5. Opcionalmente, establece `label` para el texto descriptivo del edge
6. Agrega el edge al array `edges`
7. **Valida**: Confirma que tanto `fromNode` como `toNode` referencien IDs de nodos existentes

### 4. Editar un canvas existente

1. Lee y parsea el archivo `.canvas` como JSON
2. Localiza el nodo o edge objetivo por su `id`
3. Modifica los atributos deseados (texto, posición, color, etc.)
4. Escribe el JSON actualizado de vuelta al archivo
5. **Valida**: Revisa de nuevo la unicidad de todos los IDs y la integridad de las referencias de edges tras la edición

## Nodos

Los nodos son objetos colocados en el canvas. El orden del array determina el z-index: el primer nodo = capa inferior, el último nodo = capa superior.

### Atributos genéricos de nodo

| Atributo | Obligatorio | Tipo | Descripción |
|-----------|----------|------|-------------|
| `id` | Sí | string | Identificador hexadecimal único de 16 caracteres |
| `type` | Sí | string | `text`, `file`, `link` o `group` |
| `x` | Sí | integer | Posición X en píxeles |
| `y` | Sí | integer | Posición Y en píxeles |
| `width` | Sí | integer | Ancho en píxeles |
| `height` | Sí | integer | Alto en píxeles |
| `color` | No | canvasColor | Valor preestablecido `"1"`-`"6"` o hex (p. ej., `"#FF0000"`) |

### Nodos de texto

| Atributo | Obligatorio | Tipo | Descripción |
|-----------|----------|------|-------------|
| `text` | Sí | string | Texto plano con sintaxis Markdown |

```json
{
  "id": "6f0ad84f44ce9c17",
  "type": "text",
  "x": 0,
  "y": 0,
  "width": 400,
  "height": 200,
  "text": "# Hello World\n\nThis is **Markdown** content."
}
```

**Advertencia sobre saltos de línea**: Usa `\n` para los saltos de línea en las cadenas JSON. **No** uses el literal `\\n` -- Obsidian lo renderiza como los caracteres `\` y `n`.

**Advertencia sobre el escape de comillas**: Las comillas dobles dentro del contenido de `text` deben escaparse como `\"`. Por ejemplo, el texto `公司的"外交官"` debe almacenarse como `"text": "公司的\"外交官\""`. Las comillas sin escapar rompen el parseo del JSON y el canvas no podrá renderizarse. Al generar el JSON de un canvas de forma programática, usa siempre un serializador JSON en lugar de concatenar cadenas manualmente.

Escribe los archivos `.canvas` directamente. No los crees con `obsidian create content=`, que convierte cada `\n` en un salto de línea real y rompe el JSON.

### Nodos de archivo

| Atributo | Obligatorio | Tipo | Descripción |
|-----------|----------|------|-------------|
| `file` | Sí | string | Ruta al archivo dentro del sistema |
| `subpath` | No | string | Enlace a un encabezado o bloque (empieza con `#`) |

**Escape de rutas de archivo**: Si un nombre de archivo contiene comillas dobles, deben escaparse como `\"` en la cadena JSON. Por ejemplo, un archivo llamado `My "Notes".md` debe referenciarse como `"file": "My \"Notes\".md"`.

```json
{
  "id": "a1b2c3d4e5f67890",
  "type": "file",
  "x": 500,
  "y": 0,
  "width": 400,
  "height": 300,
  "file": "Attachments/diagram.png"
}
```

### Nodos de enlace

| Atributo | Obligatorio | Tipo | Descripción |
|-----------|----------|------|-------------|
| `url` | Sí | string | URL externa |

```json
{
  "id": "c3d4e5f678901234",
  "type": "link",
  "x": 1000,
  "y": 0,
  "width": 400,
  "height": 200,
  "url": "https://obsidian.md"
}
```

### Nodos de grupo

Los grupos son contenedores visuales para organizar otros nodos. Coloca los nodos hijos dentro de los límites del grupo.

| Atributo | Obligatorio | Tipo | Descripción |
|-----------|----------|------|-------------|
| `label` | No | string | Etiqueta de texto para el grupo |
| `background` | No | string | Ruta a la imagen de fondo |
| `backgroundStyle` | No | string | `cover`, `ratio` o `repeat` |

```json
{
  "id": "d4e5f6789012345a",
  "type": "group",
  "x": -50,
  "y": -50,
  "width": 1000,
  "height": 600,
  "label": "Project Overview",
  "color": "4"
}
```

## Edges

Los edges conectan nodos mediante los IDs `fromNode` y `toNode`.

| Atributo | Obligatorio | Tipo | Por defecto | Descripción |
|-----------|----------|------|---------|-------------|
| `id` | Sí | string | - | Identificador único |
| `fromNode` | Sí | string | - | ID del nodo origen |
| `fromSide` | No | string | - | `top`, `right`, `bottom` o `left` |
| `fromEnd` | No | string | `none` | `none` o `arrow` |
| `toNode` | Sí | string | - | ID del nodo destino |
| `toSide` | No | string | - | `top`, `right`, `bottom` o `left` |
| `toEnd` | No | string | `arrow` | `none` o `arrow` |
| `color` | No | canvasColor | - | Color de la línea |
| `label` | No | string | - | Etiqueta de texto |

```json
{
  "id": "0123456789abcdef",
  "fromNode": "6f0ad84f44ce9c17",
  "fromSide": "right",
  "toNode": "a1b2c3d4e5f67890",
  "toSide": "left",
  "toEnd": "arrow",
  "label": "leads to"
}
```

## Colores

El tipo `canvasColor` acepta una cadena hex o un número preestablecido:

| Preestablecido | Color |
|--------|-------|
| `"1"` | Rojo |
| `"2"` | Naranja |
| `"3"` | Amarillo |
| `"4"` | Verde |
| `"5"` | Cian |
| `"6"` | Púrpura |

Los valores de color preestablecidos están intencionalmente indefinidos -- cada aplicación usa sus propios colores de marca.

## Generación de IDs

Genera cadenas hexadecimales en minúsculas de 16 caracteres (valor aleatorio de 64 bits):

```
"6f0ad84f44ce9c17"
"a3b2c1d0e9f8a7b6"
```

## Directrices de maquetación

- Las coordenadas pueden ser negativas (el canvas se extiende infinitamente)
- `x` aumenta hacia la derecha, `y` aumenta hacia abajo; la posición es la esquina superior izquierda
- Separa los nodos entre 50 y 100px; deja un padding de 20-50px dentro de los grupos
- Alinea a la cuadrícula (múltiplos de 10 o 20) para obtener maquetaciones más limpias

| Tipo de nodo | Ancho sugerido | Alto sugerido | Ancho CJK (1.5x) |
|-----------|-----------------|------------------|-------------------|
| Texto pequeño | 200-300 | 80-150 | 300-450 |
| Texto mediano | 300-450 | 150-300 | 450-675 |
| Texto grande | 400-600 | 300-500 | 600-900 |
| Vista previa de archivo | 300-500 | 200-400 | 450-750 |
| Vista previa de enlace | 250-400 | 100-200 | 375-600 |

**Dimensionamiento de texto CJK**: Los caracteres CJK (chino, japonés, coreano) son más anchos que los caracteres latinos. Para contenido principalmente en idiomas CJK, multiplica el ancho sugerido por ~1.5× para evitar maquetaciones apretadas y saltos de línea incómodos.

## Lista de verificación de validación

Tras crear o editar un archivo canvas, verifica:

1. Todos los valores de `id` son únicos tanto en nodos como en edges
2. Cada `fromNode` y `toNode` referencia un ID de nodo existente
3. Los campos obligatorios están presentes para cada tipo de nodo (`text` para nodos de texto, `file` para nodos de archivo, `url` para nodos de enlace)
4. `type` es uno de: `text`, `file`, `link`, `group`
5. Los valores de `fromSide`/`toSide` son uno de: `top`, `right`, `bottom`, `left`
6. Los valores de `fromEnd`/`toEnd` son uno de: `none`, `arrow`
7. Los colores preestablecidos son `"1"` a `"6"` o un hex válido (p. ej., `"#FF0000"`)
8. Las comillas dobles en los valores de `text` y `file` están correctamente escapadas como `\"`
9. El JSON es válido y parseable

Si la validación falla, busca IDs duplicados, referencias de edges colgantes o cadenas JSON mal formadas (especialmente saltos de línea sin escapar en el contenido de texto).

## Ejemplos completos

Consulta [references/EXAMPLES.md](references/EXAMPLES.md) para ver ejemplos de canvas completos, incluidos mapas mentales, tableros de proyecto, canvas de investigación y diagramas de flujo.

## Referencias

- [JSON Canvas Spec 1.0](https://jsoncanvas.org/spec/1.0/)
- [JSON Canvas GitHub](https://github.com/obsidianmd/jsoncanvas)
