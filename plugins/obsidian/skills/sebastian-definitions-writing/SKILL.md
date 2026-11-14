---
name: sebastian-definitions-writing
description: How to create and maintain definition notes in Sebastian's Obsidian vault glossary at P:\.obsidian\sebastian\definitions — the ACTIVE dictionary consumed by the Note Definitions plugin (hover popovers in every note of the vault). Covers the exact frontmatter schema (def-type/version/id/status/category/contexto/date/tags/aliases), term naming rules (basename + aliases become matchable phrases), the atomic body template, the status lifecycle (estandar→consolidado→finalizado→obsoleto), duplicate-term collision checks, and the plugin mechanics (atomic parser, dash divider, autoPlurals, 150×150 popover). Use whenever the user asks to define a term, add a glossary entry, create/edit a definition, fix or consolidate a definition note, or says things like "añade la definición de X", "define X", "nueva entrada del glosario", "actualiza la definición", "esa definición está obsoleta" — or when creating any .md file inside sebastian/definitions/.
---

# El glosario de Sebastian (`sebastian/definitions/`) — diccionario activo del vault

## 0. Requisito: plugin **Note Definitions**

Esta skill gestiona el glosario que consume el plugin comunitario de Obsidian **Note Definitions**. Si el vault donde se va a trabajar no lo tiene instalado y activado, instálalo ANTES de crear o editar definiciones:

1. En Obsidian: Settings → Community plugins → Browse → buscar **"Note Definitions"** → Install → Enable. Enlace directo: <https://community.obsidian.md/plugins/note-definitions>.
2. Tras activarlo, configurar `defFolder: sebastian/definitions` (Settings → Note Definitions → Definitions folder) y verificar que `divider.dash` y `autoPlurals` están activados (§1).
3. Verificación rápida: abre cualquier nota del vault y comprueba que los términos del glosario se subrayan con puntos amarillos al pasar el ratón.

Si el plugin no está disponible (por ejemplo, en un vault ajeno), NO crees ni edites definiciones: el esquema de esta skill solo tiene sentido con el plugin como consumidor.

---

`P:\.obsidian\sebastian\definitions\` NO es una carpeta de notas: es el **diccionario activo** que consume el plugin **Note Definitions** (config: `defFolder: sebastian/definitions`). Cada archivo registra un TÉRMINO que funciona en todo el vault: al pasar el ratón sobre la palabra o frase en cualquier nota, Obsidian la subraya con puntos amarillos y muestra un **popover** con el cuerpo de esa nota. El plugin es el consumidor; el esquema frontmatter es el contrato.

## 1. Mecánica del plugin (por qué cada regla importa)

| Mecanismo | Setting actual | Consecuencia para ti |
|---|---|---|
| Descubrimiento por carpeta | `defFolder: sebastian/definitions`, tag discovery OFF | Solo los .md de esa carpeta registran términos; no busques tags |
| Tipo de archivo | `def-type: atomic` es el default (1 archivo = 1 término) | SIEMPRE atomic; Sebastian nunca usa `consolidated` (1 archivo = varios términos con `%%END%%`) |
| Término principal | basename del archivo (p. ej. `zero-day.md` → "zero day") | El filename ES el término: kebab-case, sin acentos en slugs |
| Divisor de guiones | `divider.dash: true` | Los guiones del filename se leen como espacios: `zero-day` matchea "zero day" Y "zero-day" |
| Alias | frontmatter `aliases` (lista YAML) | Cada alias es una frase matcheable adicional; el término español canónico va SIEMPRE como alias |
| Plurales automáticos | `autoPlurals: true` | No añadas variantes de plural a aliases ("data mesh" ya matchea "data meshes") |
| Case | insensible | No añadas variantes de mayúscula a aliases |
| Popover | hover, 150×150 px, aliases ocultas, nombre de archivo oculto | La PRIMERA frase del cuerpo carga todo el peso: debe ser autosuficiente y definitoria; el popover es pequeño |
| Duplicados | detector integrado de términos/alias repetidos entre archivos | Dos archivos con el mismo término o alias normalizado disparan el modal de duplicados: prohíbido |
| Otros campos | el plugin los IGNORA | `id`, `status`, `category`, `contexto`, `date`, `tags`, `version` son el ciclo de vida personal de Sebastian: mantenlos intactos, no los borres |

Ojo con colisiones silenciosas: `post-quantum cryptography.md` (con espacio) y `post-quantum-cryptography.md` (con guion) se normalizan a la MISMA frase por el divisor de guiones — es un duplicado real ya existente. Antes de crear un término, verifica colisiones (§7).

## 2. Plantilla exacta de una definición nueva

```markdown
---
def-type: atomic
version: 1.0
id: def-<slug-kebab-único>
status: estandar
category: <categoría-kebab-español>
contexto: <dominio-kebab-español>
date: YYYY-MM-DD
tags:
  - <tag 1>
  - <tag 2>
  - <tag 3>
aliases:
  - <término español canónico>
  - <término inglés>
  - <abreviatura o variante>
---
<Frase definitoria de apertura: qué ES el término, en 1-3 frases, en español.>

### <Sección>

-  **Elemento**: explicación…

### Propósito fundamental

<Síntesis final en prosa.>
```

Reglas de cada campo:

- `def-type: atomic` — fijo, no se discute.
- `version: 1.0` — siempre decimal ("1.0", no "1"; las variantes antiguas "1", "1.1" y "1.2" son historia del corpus, no las repliques: en notas nuevas siempre 1.0).
- `id: def-<slug>` — único en toda la carpeta; el slug suele ser el término español kebab (`def-patrimonio`, `def-whaling`) y puede divergir del filename.
- `status:` — ciclo de vida (§5): `estandar` al crear.
- `category:` — kebab español libre (vocabulario NO controlado; usa el valor más usado del tema en la carpeta: `inteligencia-artificial`, `finanzas`, `protocolos-de-red`, `criptografía`, `amenazas`, `contabilidad`…). Respeta la acentuación del valor dominante existente, no inventes variantes (`criptografia` vs `criptografía` ya conviven — no añadas una tercera).
- `contexto:` — dominio de aplicación (`ciberseguridad`, `ciencia-de-datos`, `bases-de-datos`…). Puede omitirse solo si el término es transversal; Sebastian lo incluía siempre hasta sep-2026 y a veces lo omite ahora — en dudas, inclúyelo.
- `date:` — ISO `YYYY-MM-DD` (Europe/Madrid).
- `tags:` — 3-5, lowercase, mezcla español/inglés según término (`seguridad`, `arquitectura`, `cloud`, `pqc`…).
- `aliases:` — orden de Sebastian: [término español canónico, término inglés, abreviatura/variantes]. El primer alias NO debe repetir el filename literal (son frases distintas: filename inglés-kebab ↔ alias español). No incluyas plurales ni variantes de mayúscula (el plugin ya las genera).

## 3. Cuerpo: plantilla atomic

1. **Apertura directa** — la primera frase ES la definición. Sin H1, sin encabezado "Definición:", sin intro. La frase debe funcionar sola dentro de un popover de 150×150.
2. **Secciones** con `###` (o `####` en notas largas; nunca `##`). Títulos cortos, sustantivos; el cierre canónico actual es `### Propósito fundamental` (era más reciente del esquema; variar títulos por dominio es válido).
3. **Bullets con lead en negrita** `-  **Término**: explicación…` (guion + dos espacios + negrita — la firma universal del vault).
4. **Español** con tecnicismos inglés; extranjerismos en cursiva (`_zero day_`, `_benchmark_`).
5. **Matemáticas** permitidas en LaTeX cuando el término es estadístico (`$|x - \mu|$`).
6. **SIN wikilinks en el cuerpo** — las definiciones son átomos aislados; el popover no debe abrir grafo ni depender de contexto. Única excepción histórica: un `**Parent:: [[…]]**` aislado (no lo repliques).
7. **Imágenes**: prácticamente nunca (popover 150×150); si un diagrama es imprescindible, embed por nombre desnudo `![[imagen.jpg]]` desde `assets/multimedia/`.
8. **Cierre**: párrafo de síntesis en prosa (~50% de las notas) o sección final; no uses fórmulas fijas tipo "En resumen…".
9. Longitud típica: 15-40 líneas. Términos simples pueden ser más cortos.

## 4. Nombrar el archivo y los aliases (lo más importante)

1. **Filename = término en inglés kebab-case** cuando el término es de origen inglés (`zero-day.md`, `data-mesh.md`, `root-ca.md`).
2. Si el concepto no tiene nombre inglés natural, usa el término español kebab sin acentos como filename (`pseudocodigo.md`, `distribución-bimodal.md` es histórico — NO añadas acentos a filenames nuevos; kebab ASCII).
3. **Aliases cubren lo que el filename no cubre**: español canónico primero, inglés, abreviaturas (`root-ca.md`: `CA`, `root ca`, `autoridad de certificacion raiz`, `root certificate authority` — sin acentos en aliases está bien, el matching es por frase).
4. Alias nunca = filename literal; alias nunca duplicado de otro archivo (§7).
5. El basename es el término "oficial" para el grafo, pero el popover funciona con TODAS las frases — por eso Sebastian documenta conceptos españoles bajo filenames ingleses.

## 5. Ciclo de vida (`status` + `version`)

| status | Significado | Cuándo |
|---|---|---|
| `estandar` | definición nueva o estable | al crear (219/229 viven aquí) |
| `consolidado` | revisada y reforzada | tras una revisión profunda (bump `version` 1.0 → 1.1) |
| `finalizado` | cerrada, no requiere más trabajo | decisión explícita |
| `obsoleto` | término muerto tecnológico | ej. `teletype-network.md` (Telnet) |

Reglas: `date:` es la fecha de creación/revisión. Al revisar contenido sustantivo, sube `version` (1.0 → 1.1 → 1.2) y NO cambies `date` a menos que sea la revisión actual. No introduzcas valores de status nuevos.

## 6. Cuándo crear una definición (y cuándo no)

Crea una entrada cuando:

- El término aparece de forma recurrente en notas de estudio (cloud, labs, cybersicherheit, finanzas) y merece popover en todo el vault.
- Sebastian pide "define X", "añade al glosario", "no sé qué es X" en contexto de estudio.
- Un concepto que ya existe como nota de contenido en otra área se quiere estandarizar como átomo consultable (la definición vive en `definitions/`; la nota de contenido NO se convierte en wikilink hacia ella — siguen siendo mundos separados).

NO crees una entrada cuando:

- El término ya tiene archivo (busca primero, §7) — actualiza el existente.
- Es un nombre propio de producto muy específico con contenido en su nota de vendor (eso va al área cloud, no al glosario) — salvo que el término se use transversalmente.
- Es una nota de tarea, lab o colegio (esos tipos tienen sus propias skills/convenciones).

## 7. Anti-colisión: verifica ANTES de crear

```bash
# 1. ¿Existe ya el archivo?
ls /p/.obsidian/sebastian/definitions | grep -i "<slug>"
# 2. ¿Alguien usa ese término o alias como frase? (guiones y espacios son equivalentes para el plugin)
grep -ril "<slug>" /p/.obsidian/sebastian/definitions/
grep -ri "<término español>" /p/.obsidian/sebastian/definitions/
# 3. ¿El id def-<slug> está libre?
grep -r "id: def-<slug>" /p/.obsidian/sebastian/definitions/
```

Deuda conocida (NO la repliques, puedes señalarla si la tocas):

- 2 ids duplicados: `def-data-access-patterns` (en `data-access-patterns.md` y `data-access-strategies.md`) y `def-obligacion-fiscal` (en `hierarchy-of-accounting-accounts.md` y `tax-obligation.md`).
- Duplicado de frase real: `post-quantum cryptography.md` vs `post-quantum-cryptography.md`.
- `open-quantum-safe.md` tiene el frontmatter VACÍO (`---\n\n---`) — el plugin lo trataría como tipo default (atomic) por settings, pero es un bug a reparar si se toca.
- Filename con typo: `advanced-persistent-theat.md` (→ apt). No lo renombres sin pedir confirmación: cambiar el filename cambia el término matcheable en todo el vault.

## 8. Anti-patrones

- ❌ `def-type: consolidated` o secciones con `%%END%%`.
- ❌ H1/título de encabezado al inicio del cuerpo; opener "Definición:".
- ❌ Wikilinks en el cuerpo de la definición.
- ❌ Añadir plurales o variantes de mayúscula a `aliases` (autoPlurals + case-insensitive ya lo cubren).
- ❌ Repetir un término/alias que otro archivo ya registra.
- ❌ Filenames nuevos con acentos, espacios (existe un caso histórico, no repliques) o caracteres Unicode.
- ❌ Frontmatter sin campos (nunca `---` vacío) ni campos extra inventados.
- ❌ Reordenar/renombrar campos del esquema al editar una definición existente: conserva su orden y sus valores salvo la revisión pedida.
- ❌ Borrar una definición: si el término muere, `status: obsoleto`.

## 9. Checklist antes de guardar

1. ¿Filename = término inglés/español kebab ASCII, sin colisión de frase normalizada?
2. ¿`id: def-<slug>` único?
3. ¿Aliases: [español canónico, inglés, abreviatura] sin plurales/mayúsculas ni duplicados?
4. ¿Primera frase autosuficiente como definición popover (150×150)?
5. ¿Cuerpo en español, bullets `-  **…**`, secciones `###`/`####`, sin wikilinks, cierre con síntesis o `### Propósito fundamental`?
6. ¿Campos lifecycle completos (version 1.0, status estandar, category, contexto, date, tags)?
7. ¿Verificados los 3 grep anti-colisión de §7?
