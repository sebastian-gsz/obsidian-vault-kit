# Functions Reference

## Funciones globales

| Función | Firma | Descripción |
|----------|-----------|-------------|
| `date()` | `date(string): date` | Convierte una cadena en fecha. Formato: `YYYY-MM-DD HH:mm:ss` |
| `duration()` | `duration(string): duration` | Convierte una cadena en duración |
| `now()` | `now(): date` | Fecha y hora actuales |
| `today()` | `today(): date` | Fecha actual (hora = 00:00:00) |
| `if()` | `if(condition, trueResult, falseResult?)` | Condicional |
| `min()` | `min(n1, n2, ...): number` | Número más pequeño |
| `max()` | `max(n1, n2, ...): number` | Número más grande |
| `number()` | `number(any): number` | Convierte a número |
| `link()` | `link(path, display?): Link` | Crea un enlace |
| `list()` | `list(element): List` | Envuelve en una lista si aún no lo es |
| `file()` | `file(path): file` | Obtiene el objeto file |
| `image()` | `image(path): image` | Crea una imagen para renderizar |
| `icon()` | `icon(name): icon` | Icono Lucide por nombre |
| `html()` | `html(string): html` | Renderiza como HTML |
| `escapeHTML()` | `escapeHTML(string): string` | Escapa caracteres HTML |

## Funciones del tipo Any

| Función | Firma | Descripción |
|----------|-----------|-------------|
| `isTruthy()` | `any.isTruthy(): boolean` | Convierte a booleano |
| `isType()` | `any.isType(type): boolean` | Comprueba el tipo |
| `toString()` | `any.toString(): string` | Convierte a cadena |

## Funciones y campos de Date

**Campos:** `date.year`, `date.month`, `date.day`, `date.hour`, `date.minute`, `date.second`, `date.millisecond`

| Función | Firma | Descripción |
|----------|-----------|-------------|
| `date()` | `date.date(): date` | Elimina la porción de hora |
| `format()` | `date.format(string): string` | Formatea con un patrón de Moment.js |
| `time()` | `date.time(): string` | Obtiene la hora como cadena |
| `relative()` | `date.relative(): string` | Tiempo relativo legible por humanos |
| `isEmpty()` | `date.isEmpty(): boolean` | Siempre false para fechas |

## Tipo Duration

Al restar dos fechas, el resultado es de tipo **Duration** (no un número). Duration tiene sus propias propiedades y métodos.

**Campos de Duration:**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `duration.days` | Number | Días totales en la duración |
| `duration.hours` | Number | Horas totales en la duración |
| `duration.minutes` | Number | Minutos totales en la duración |
| `duration.seconds` | Number | Segundos totales en la duración |
| `duration.milliseconds` | Number | Milisegundos totales en la duración |

**IMPORTANTE:** Duration NO soporta `.round()`, `.floor()`, `.ceil()` directamente. Debes acceder primero a un campo numérico (como `.days`) y luego aplicar las funciones de número.

```yaml
# CORRECT: Calculate days between dates
"(date(due_date) - today()).days"                    # Returns number of days
"(now() - file.ctime).days"                          # Days since created

# CORRECT: Round the numeric result if needed
"(date(due_date) - today()).days.round(0)"           # Rounded days
"(now() - file.ctime).hours.round(0)"                # Rounded hours

# WRONG - will cause error:
# "((date(due) - today()) / 86400000).round(0)"      # Duration doesn't support division then round
```

## Aritmética de fechas

```yaml
# Duration units: y/year/years, M/month/months, d/day/days,
#                 w/week/weeks, h/hour/hours, m/minute/minutes, s/second/seconds

# Add/subtract durations
"date + \"1M\""           # Add 1 month
"date - \"2h\""           # Subtract 2 hours
"now() + \"1 day\""       # Tomorrow
"today() + \"7d\""        # A week from today

# Subtract dates returns Duration type
"now() - file.ctime"                    # Returns Duration
"(now() - file.ctime).days"             # Get days as number
"(now() - file.ctime).hours"            # Get hours as number

# Complex duration arithmetic
"now() + (duration('1d') * 2)"
```

## Funciones de String

**Campo:** `string.length`

| Función | Firma | Descripción |
|----------|-----------|-------------|
| `contains()` | `string.contains(value): boolean` | Comprueba una subcadena |
| `containsAll()` | `string.containsAll(...values): boolean` | Todas las subcadenas presentes |
| `containsAny()` | `string.containsAny(...values): boolean` | Alguna subcadena presente |
| `startsWith()` | `string.startsWith(query): boolean` | Empieza por query |
| `endsWith()` | `string.endsWith(query): boolean` | Termina con query |
| `isEmpty()` | `string.isEmpty(): boolean` | Vacía o no presente |
| `lower()` | `string.lower(): string` | A minúsculas |
| `title()` | `string.title(): string` | A Title Case |
| `trim()` | `string.trim(): string` | Elimina espacios en blanco |
| `replace()` | `string.replace(pattern, replacement): string` | Reemplaza el patrón |
| `repeat()` | `string.repeat(count): string` | Repite la cadena |
| `reverse()` | `string.reverse(): string` | Invierte la cadena |
| `slice()` | `string.slice(start, end?): string` | Subcadena |
| `split()` | `string.split(separator, n?): list` | Divide en una lista |

## Funciones de Number

| Función | Firma | Descripción |
|----------|-----------|-------------|
| `abs()` | `number.abs(): number` | Valor absoluto |
| `ceil()` | `number.ceil(): number` | Redondea hacia arriba |
| `floor()` | `number.floor(): number` | Redondea hacia abajo |
| `round()` | `number.round(digits?): number` | Redondea a digits decimales |
| `toFixed()` | `number.toFixed(precision): string` | Notación de punto fijo |
| `isEmpty()` | `number.isEmpty(): boolean` | No presente |

## Funciones de List

**Campo:** `list.length`

| Función | Firma | Descripción |
|----------|-----------|-------------|
| `contains()` | `list.contains(value): boolean` | El elemento existe |
| `containsAll()` | `list.containsAll(...values): boolean` | Todos los elementos existen |
| `containsAny()` | `list.containsAny(...values): boolean` | Algún elemento existe |
| `filter()` | `list.filter(expression): list` | Filtra por condición (usa `value`, `index`) |
| `map()` | `list.map(expression): list` | Transforma los elementos (usa `value`, `index`) |
| `reduce()` | `list.reduce(expression, initial): any` | Reduce a un único valor (usa `value`, `index`, `acc`) |
| `flat()` | `list.flat(): list` | Aplana listas anidadas |
| `join()` | `list.join(separator): string` | Une en una cadena |
| `reverse()` | `list.reverse(): list` | Invierte el orden |
| `slice()` | `list.slice(start, end?): list` | Sublista |
| `sort()` | `list.sort(): list` | Ordena ascendente |
| `unique()` | `list.unique(): list` | Elimina duplicados |
| `isEmpty()` | `list.isEmpty(): boolean` | Sin elementos |

## Funciones de File

| Función | Firma | Descripción |
|----------|-----------|-------------|
| `asLink()` | `file.asLink(display?): Link` | Convierte a enlace |
| `hasLink()` | `file.hasLink(otherFile): boolean` | Tiene enlace al archivo |
| `hasTag()` | `file.hasTag(...tags): boolean` | Tiene alguna de las etiquetas |
| `hasProperty()` | `file.hasProperty(name): boolean` | Tiene la propiedad |
| `inFolder()` | `file.inFolder(folder): boolean` | Está en la carpeta o subcarpeta |

## Funciones de Link

| Función | Firma | Descripción |
|----------|-----------|-------------|
| `asFile()` | `link.asFile(): file` | Obtiene el objeto file |
| `linksTo()` | `link.linksTo(file): boolean` | Enlaza al archivo |

## Funciones de Object

| Función | Firma | Descripción |
|----------|-----------|-------------|
| `isEmpty()` | `object.isEmpty(): boolean` | Sin propiedades |
| `keys()` | `object.keys(): list` | Lista de claves |
| `values()` | `object.values(): list` | Lista de valores |

## Funciones de expresiones regulares

| Función | Firma | Descripción |
|----------|-----------|-------------|
| `matches()` | `regexp.matches(string): boolean` | Comprueba si coincide |
