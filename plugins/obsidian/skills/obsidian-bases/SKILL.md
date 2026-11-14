---
name: obsidian-bases
description: Crea y edita Obsidian Bases (archivos .base) con vistas, filtros, fórmulas y resúmenes. Úsalo cuando trabajes con archivos .base, crees vistas tipo base de datos de notas, o cuando el usuario mencione Bases, vistas de tabla, vistas de tarjetas, tableros kanban, filtros o fórmulas en Obsidian.
---

# Obsidian Bases Skill

## Flujo de trabajo

1. **Crear el archivo**: Crea un archivo `.base` en el vault con contenido YAML válido
2. **Definir el alcance**: Añade `filters` para seleccionar qué notas aparecen (por etiqueta, carpeta, propiedad o fecha)
3. **Añadir fórmulas** (opcional): Define propiedades calculadas en la sección `formulas`
4. **Configurar vistas**: Añade una o más vistas (`table`, `cards`, `list`, `map` o `kanban`) con `order` indicando qué propiedades mostrar
5. **Validar**: Verifica que el archivo es YAML válido sin errores de sintaxis. Comprueba que todas las propiedades y fórmulas referenciadas existen. Problemas comunes: cadenas sin comillas que contienen caracteres especiales de YAML, comillas no emparejadas en expresiones de fórmulas, o referencias a `formula.X` sin haber definido `X` en `formulas`
6. **Probar en Obsidian**: Abre el archivo `.base` en Obsidian para confirmar que la vista se renderiza correctamente. Si muestra un error de YAML, revisa las reglas de comillas de abajo. Si no se abre como base, verifica que Bases esté activado en Settings → Core plugins

## Esquema

Los archivos base usan la extensión `.base` y contienen YAML válido.

```yaml
# Global filters apply to ALL views in the base
filters:
  # Can be a single filter string
  # OR a recursive filter object with exactly ONE key: and, or, or not
  and:
    - 'status == "active"'
    - not:
        - 'file.hasTag("archived")'

# Define formula properties that can be used across all views
formulas:
  formula_name: 'expression'

# Configure display names and settings for properties.
# Note properties need the `note.` prefix here, or the setting is ignored.
properties:
  note.property_name:
    displayName: "Display Name"
  formula.formula_name:
    displayName: "Formula Display Name"
  file.ext:
    displayName: "Extension"

# Define custom summary formulas
summaries:
  custom_summary_name: 'values.mean().round(3)'

# Define one or more views
views:
  - type: table | cards | list | map | kanban
    name: "View Name"
    limit: 10                    # Optional: limit results
    groupBy:                     # Optional: group results
      property: property_name
      direction: ASC | DESC
    groupOrder:                  # Optional: only these groups, in this order
      - value_one
      - null                     # Files with no value for the groupBy property
    sort:                        # Optional: sort results (supports multiple properties)
      - property: property_name
        direction: ASC | DESC
    filters:                     # View-specific filters follow the same rules
      and:
        - 'status == "active"'
    order:                       # Properties to display in order
      - file.name
      - property_name
      - formula.formula_name
    summaries:                   # Map properties to summary formulas
      property_name: Average
```

## Sintaxis de filtros

Los filtros reducen los resultados. Se pueden aplicar globalmente o por vista.

### Estructura de filtros

```yaml
# Single filter
filters: 'status == "done"'

# AND - all conditions must be true
filters:
  and:
    - 'status == "done"'
    - 'priority > 3'

# OR - any condition can be true
filters:
  or:
    - 'file.hasTag("book")'
    - 'file.hasTag("article")'

# NOT - exclude matching items
filters:
  not:
    - 'file.hasTag("archived")'

# Nested filters
filters:
  or:
    - file.hasTag("tag")
    - and:
        - file.hasTag("book")
        - file.hasLink("Textbook")
    - not:
        - file.hasTag("book")
        - file.inFolder("Required Reading")
```

### Operadores de filtro

| Operador | Descripción |
|----------|-------------|
| `==` | igual a |
| `!=` | distinto de |
| `>` | mayor que |
| `<` | menor que |
| `>=` | mayor o igual |
| `<=` | menor o igual |
| `&&` | y lógico |
| `\|\|` | o lógico |
| <code>!</code> | negación lógica |

## Propiedades

### Tres tipos de propiedades

1. **Propiedades de nota** - Del frontmatter: `note.author` o simplemente `author`
2. **Propiedades de archivo** - Metadatos del archivo: `file.name`, `file.mtime`, etc.
3. **Propiedades de fórmula** - Valores calculados: `formula.my_formula`

En `order`, `filters`, `groupBy` y `sort`, una propiedad de nota puede escribirse sin prefijo (`author`) o con prefijo (`note.author`). En la sección `properties:` de nivel superior, escribe siempre `note.author`, porque Obsidian ignora ahí una clave sin prefijo y muestra el nombre crudo como encabezado de columna.

### Referencia de propiedades de archivo

| Propiedad | Tipo | Descripción |
|----------|------|-------------|
| `file.name` | String | Nombre del archivo |
| `file.basename` | String | Nombre del archivo sin extensión |
| `file.path` | String | Ruta completa al archivo |
| `file.folder` | String | Ruta de la carpeta contenedora |
| `file.ext` | String | Extensión del archivo |
| `file.size` | Number | Tamaño del archivo en bytes |
| `file.ctime` | Date | Fecha de creación |
| `file.mtime` | Date | Fecha de modificación |
| `file.tags` | List | Todas las etiquetas del archivo |
| `file.links` | List | Enlaces internos del archivo |
| `file.backlinks` | List | Archivos que enlazan a este archivo. Lento en vaults grandes y no se actualiza cuando el vault cambia; prefiere invertir la búsqueda con `file.links` |
| `file.embeds` | List | Embeds en la nota |
| `file.properties` | Object | Todas las propiedades del frontmatter. No se actualiza cuando el vault cambia |
| `file.file` | File | Objeto File, solo utilizable en funciones específicas |

### La palabra clave `this`

- En el área de contenido principal: se refiere al propio archivo base
- Cuando está embebido: se refiere al archivo que lo embebe
- En la barra lateral: se refiere al archivo activo en el contenido principal

## Sintaxis de fórmulas

Las fórmulas calculan valores a partir de propiedades. Se definen en la sección `formulas`.

```yaml
formulas:
  # Simple arithmetic
  total: "price * quantity"

  # Conditional logic
  status_icon: 'if(done, "✅", "⏳")'

  # String formatting
  formatted_price: 'if(price, price.toFixed(2) + " dollars")'

  # Date formatting
  created: 'file.ctime.format("YYYY-MM-DD")'

  # Calculate days since created (use .days for Duration)
  days_old: '(now() - file.ctime).days'

  # Calculate days until due date
  days_until_due: 'if(due_date, (date(due_date) - today()).days, "")'
```

## Funciones clave

Las funciones más usadas. Para la referencia completa de todos los tipos (Date, String, Number, List, File, Link, Object, RegExp), consulta [FUNCTIONS_REFERENCE.md](references/FUNCTIONS_REFERENCE.md).

| Función | Firma | Descripción |
|----------|-----------|-------------|
| `date()` | `date(string): date` | Convierte una cadena en fecha (`YYYY-MM-DD HH:mm:ss`) |
| `now()` | `now(): date` | Fecha y hora actuales |
| `today()` | `today(): date` | Fecha actual (hora = 00:00:00) |
| `if()` | `if(condition, trueResult, falseResult?)` | Condicional |
| `duration()` | `duration(string): duration` | Convierte una cadena en duración |
| `file()` | `file(path): file` | Obtiene el objeto file |
| `link()` | `link(path, display?): Link` | Crea un enlace |

### Tipo Duration

Al restar dos fechas, el resultado es de tipo **Duration** (no un número).

**Campos de Duration:** `duration.days`, `duration.hours`, `duration.minutes`, `duration.seconds`, `duration.milliseconds`

**IMPORTANTE:** Duration NO soporta `.round()`, `.floor()`, `.ceil()` directamente. Accede primero a un campo numérico (como `.days`) y luego aplica las funciones de número.

```yaml
# CORRECT: Calculate days between dates
"(date(due_date) - today()).days"                    # Returns number of days
"(now() - file.ctime).days"                          # Days since created
"(date(due_date) - today()).days.round(0)"           # Rounded days

# WRONG - will cause error:
# "((date(due) - today()) / 86400000).round(0)"      # Duration doesn't support division then round
```

### Aritmética de fechas

```yaml
# Duration units: y/year/years, M/month/months, d/day/days,
#                 w/week/weeks, h/hour/hours, m/minute/minutes, s/second/seconds
"now() + \"1 day\""       # Tomorrow
"today() + \"7d\""        # A week from today
"now() - file.ctime"      # Returns Duration
"(now() - file.ctime).days"  # Get days as number
```

## Tipos de vistas

### Vista de tabla (table)

```yaml
views:
  - type: table
    name: "My Table"
    order:
      - file.name
      - status
      - due_date
    summaries:
      price: Sum
      count: Average
```

### Vista de tarjetas (cards)

```yaml
views:
  - type: cards
    name: "Gallery"
    order:
      - file.name
      - cover_image
      - description
```

### Vista de lista (list)

```yaml
views:
  - type: list
    name: "Simple List"
    order:
      - file.name
      - status
```

### Vista kanban

Requiere Obsidian 1.14+. Las tarjetas se agrupan en columnas por la propiedad `groupBy`, que una vista kanban necesita. `groupOrder` define qué columnas se muestran y en qué orden; usa `null` para incluir archivos sin valor. Sin `groupOrder`, cada valor recibe una columna. Arrastrar una tarjeta a otra columna actualiza esa propiedad en la nota. Solo las notas Markdown pueden moverse, excepto al agrupar por `file.folder`, caso en el que mover una tarjeta mueve el archivo a esa carpeta. Al agrupar por una fórmula o por una propiedad de archivo distinta de `file.folder`, las tarjetas y columnas no se pueden mover y no se pueden crear notas desde una columna.

```yaml
views:
  - type: kanban
    name: "Projects"
    groupBy:
      property: note.status
      direction: ASC
    groupOrder:
      - Planned
      - In progress
      - Done
    order:
      - file.name
      - due_date
```

### Vista de mapa (map)

Requiere propiedades de latitud/longitud y el plugin de la comunidad Maps.

```yaml
views:
  - type: map
    name: "Locations"
    # Map-specific settings for lat/lng properties
```

## Ordenación

Ordena los resultados por una o más propiedades. Cada entrada de ordenación especifica una `property` y una `direction`, que debe ser `ASC` o `DESC` en mayúsculas; una entrada con cualquier otro valor, o una ordenación escrita como cadena, se ignora silenciosamente. Las múltiples entradas de ordenación se aplican en orden — la primera es la clave principal de ordenación y las siguientes desempatan.

```yaml
views:
  - type: table
    name: "Sorted Tasks"
    sort:
      - property: due
        direction: ASC
      - property: file.name
        direction: ASC
    order:
      - file.name
      - due
      - status
```

Las opciones de ordenación dependen del tipo de propiedad:

| Tipo de propiedad | ASC | DESC |
|---------------|-----|------|
| Texto | A→Z | Z→A |
| Número | 0→9 | 9→0 |
| Fecha | Antiguo→Nuevo | Nuevo→Antiguo |

Puedes ordenar por cualquier propiedad, incluidas fórmulas (`formula.my_formula`), propiedades de archivo (`file.mtime`) y propiedades de nota.

## Fórmulas de resumen por defecto

| Nombre | Tipo de entrada | Descripción |
|------|------------|-------------|
| `Average` | Number | Media matemática |
| `Min` | Number | Número más pequeño |
| `Max` | Number | Número más grande |
| `Sum` | Number | Suma de todos los números |
| `Range` | Number | Max - Min |
| `Median` | Number | Mediana matemática |
| `Stddev` | Number | Desviación estándar |
| `Earliest` | Date | Fecha más antigua |
| `Latest` | Date | Fecha más reciente |
| `Range` | Date | Última - Primera |
| `Checked` | Boolean | Cantidad de valores verdaderos |
| `Unchecked` | Boolean | Cantidad de valores falsos |
| `Empty` | Any | Cantidad de valores vacíos |
| `Filled` | Any | Cantidad de valores no vacíos |
| `Unique` | Any | Cantidad de valores únicos |

## Ejemplos completos

### Base de seguimiento de tareas

```yaml
filters:
  and:
    - file.hasTag("task")
    - 'file.ext == "md"'

formulas:
  days_until_due: 'if(due, (date(due) - today()).days, "")'
  is_overdue: 'if(due, date(due) < today() && status != "done", false)'
  priority_label: 'if(priority == 1, "🔴 High", if(priority == 2, "🟡 Medium", "🟢 Low"))'

properties:
  note.status:
    displayName: Status
  formula.days_until_due:
    displayName: "Days Until Due"
  formula.priority_label:
    displayName: Priority

views:
  - type: table
    name: "Active Tasks"
    filters:
      and:
        - 'status != "done"'
    order:
      - file.name
      - status
      - formula.priority_label
      - due
      - formula.days_until_due
    groupBy:
      property: status
      direction: ASC
    sort:
      - property: due
        direction: ASC
      - property: file.name
        direction: ASC
    summaries:
      formula.days_until_due: Average

  - type: table
    name: "Completed"
    filters:
      and:
        - 'status == "done"'
    order:
      - file.name
      - completed_date
```

### Base de lista de lectura

```yaml
filters:
  or:
    - file.hasTag("book")
    - file.hasTag("article")

formulas:
  reading_time: 'if(pages, (pages * 2).toString() + " min", "")'
  status_icon: 'if(status == "reading", "📖", if(status == "done", "✅", "📚"))'
  year_read: 'if(finished_date, date(finished_date).year, "")'

properties:
  note.author:
    displayName: Author
  formula.status_icon:
    displayName: "Status"
  formula.reading_time:
    displayName: "Est. Time"

views:
  - type: cards
    name: "Library"
    order:
      - cover
      - file.name
      - author
      - formula.status_icon
    filters:
      not:
        - 'status == "dropped"'

  - type: table
    name: "Reading List"
    filters:
      and:
        - 'status == "to-read"'
    order:
      - file.name
      - author
      - pages
      - formula.reading_time
```

### Índice de notas diarias

```yaml
filters:
  and:
    - file.inFolder("Daily Notes")
    - '/^\d{4}-\d{2}-\d{2}$/.matches(file.basename)'

formulas:
  word_estimate: '(file.size / 5).round(0)'
  day_of_week: 'date(file.basename).format("dddd")'

properties:
  formula.day_of_week:
    displayName: "Day"
  formula.word_estimate:
    displayName: "~Words"

views:
  - type: table
    name: "Recent Notes"
    limit: 30
    order:
      - file.name
      - formula.day_of_week
      - formula.word_estimate
      - file.mtime
```

## Embeber Bases

### Embeber un archivo `.base`

Embebe un archivo `.base` externo en cualquier nota Markdown:

```markdown
![[MyBase.base]]

<!-- Specific view -->
![[MyBase.base#View Name]]
```

### Embeber en línea con un bloque de código

Las Bases también pueden embeberse **en línea** directamente dentro de una nota usando un bloque de código cercado `base`. Esto es útil para filtros a nivel de nota (por ejemplo, usando `this.file.links`) y evita crear un archivo `.base` aparte:

````markdown
```base
filters:
  and:
    - file.hasTag("example")
views:
  - type: table
    name: Table
    order:
      - file.name
      - status
```
````

Cuando se embebe en línea de esta manera, la palabra clave `this` se refiere a la nota contenedora, así que puedes construir vistas por nota, como mostrar todas las notas enlazadas desde el archivo actual.

## Reglas de comillas en YAML

- Usa comillas simples para fórmulas que contienen comillas dobles: `'if(done, "Yes", "No")'`
- Usa comillas dobles para cadenas simples: `"My View Name"`
- Escapa correctamente las comillas anidadas en expresiones complejas

## Solución de problemas

### Errores de sintaxis YAML

**Caracteres especiales sin comillas**: Las cadenas que contienen `:`, `{`, `}`, `[`, `]`, `,`, `&`, `*`, `#`, `?`, `|`, `-`, `<`, `>`, `=`, `%`, `@`, `` ` ``, `!` deben ir entre comillas.

```yaml
# WRONG - colon in unquoted string
displayName: Status: Active

# CORRECT
displayName: "Status: Active"
```

**Comillas no emparejadas en fórmulas**: Cuando una fórmula contiene comillas dobles, envuelve toda la fórmula en comillas simples.

```yaml
# WRONG - double quotes inside double quotes
formulas:
  label: "if(done, "Yes", "No")"

# CORRECT - single quotes wrapping double quotes
formulas:
  label: 'if(done, "Yes", "No")'
```

### Errores comunes de fórmulas

**Operaciones con Duration sin acceso a campo**: Restar fechas devuelve un Duration, no un número. Accede siempre a `.days`, `.hours`, etc.

```yaml
# WRONG - Duration is not a number
"(now() - file.ctime).round(0)"

# CORRECT - access .days first, then round
"(now() - file.ctime).days.round(0)"
```

**Faltan comprobaciones de null**: Las propiedades pueden no existir en todas las notas. Usa `if()` para protegerlas.

```yaml
# WRONG - crashes if due_date is empty
"(date(due_date) - today()).days"

# CORRECT - guard with if()
'if(due_date, (date(due_date) - today()).days, "")'
```

**`displayName` ignorado, la columna muestra el nombre crudo**: antepón `note.` a las propiedades de nota en la sección `properties:`.

```yaml
# WRONG - displayName ignored, column header shows "status"
properties:
  status:
    displayName: Status

# CORRECT - column header shows "Status"
properties:
  note.status:
    displayName: Status
```

**Un `displayName` vacío no oculta el encabezado**: `displayName: ""` retrocede al nombre de la propiedad, igual que omitirlo, así que `formula.status_icon` muestra `status_icon`. Usa un nombre no vacío como `displayName: "Status"`.

**Referencias a fórmulas no definidas**: Asegúrate de que cada `formula.X` en `order` o `properties` tiene una entrada correspondiente en `formulas`.

```yaml
# This will fail silently if 'total' is not defined in formulas
order:
  - formula.total

# Fix: define it
formulas:
  total: "price * quantity"
```

## Referencias

- [Bases Syntax](https://help.obsidian.md/bases/syntax)
- [Functions](https://help.obsidian.md/bases/functions)
- [Views](https://help.obsidian.md/bases/views)
- [Formulas](https://help.obsidian.md/formulas)
- [Complete Functions Reference](references/FUNCTIONS_REFERENCE.md)
