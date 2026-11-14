---
name: code-block-fixer
description: Reparar notas de Obsidian con código mal pegado — bloques de código insertados línea a línea como código en línea (`` ``línea`` `` o **``línea``**) en lugar de fences ```python. Los agrupa en bloques de código reales preservando indentación, separando ejemplos y sin tocar los resaltados semánticos. Úsala cuando el usuario diga que una nota tiene código que se ve como texto en línea, backticks dobles rodeando código, bloques rotos, o pida reparar/formatear/limpiar el código de una nota de estudio.
---

# Reparador de bloques de código pegados

Síntoma típico: al pegar código desde un chat o web a una nota, cada línea quedó envuelta en doble backtick (a veces con negrita):

```markdown
**``mi_lista = [1, "hola", 3.14, True] ``**
**``print(f"Lista: {mi_lista}")``**
```

En Obsidian eso se renderiza como texto en línea, no como bloque. Esta skill lo convierte en fences reales, con indentación preservada y ejemplos separados.

## Antes de ejecutar (obligatorio)

1. **Backup**: copia la nota original fuera del vault (`cp nota.md /destino/nota.md.bak`).
2. **Clasifica los chunks** de la nota. Hay tres clases y solo la primera se convierte:
   - **Chunks de código** en líneas propias (con o sin negrita, con indentación) → convertir.
   - **Chunks semánticos** (`` ``Numpy`` ``, `` ``Abstracción`` ``, `` ``La promesa:`` ``) → NO tocar: son resaltado de términos, no código.
   - **Chunks dentro de bullets de lista** (`-  **``código``**`) → NO tocar: son entradas deliberadas de lista.
3. **Detecta el lenguaje** del código (regex `python` está en el script; para otro lenguaje ajusta la constante `LANG`).

## Uso

```bash
node <skill>\scripts\fix-code-blocks.js "P:\ruta\a\nota.md"      # transformación principal
node <skill>\scripts\normalize-indent.js "P:\ruta\a\nota.md"     # tabs del indent relativo -> 4 espacios
```

## Qué hace `fix-code-blocks.js`

- Detecta líneas cuyo contenido completo es un chunk (regex tolerante: negritas, espacios finales, `º` y backticks sueltos tras el cierre).
- **Agrupa chunks consecutivos en un solo fence**, conservando líneas en blanco internas (separadores de ejemplo como `# Otro` o `# Salida:` quedan dentro del bloque).
- **Separador semántico**: un chunk que empieza por `def `/`class ` con un grupo ya abierto cierra el fence y abre otro — los ejemplos independientes no se fusionan.
- **Preserva indentación relativa**: la primera línea del grupo fija la base; a las demás se les resta el prefijo común. Un `    ``print(...)` `` indentado 4 espacios fuera del backtick se convierte en indentación Python dentro del fence.
- Emite fences ``` ```python ``` con la indentación base del grupo (la de la lista, si la nota usa listas).
- Nunca toca: fences existentes, líneas de un solo backtick, código indentado sin backticks (que ya es bloque válido).

## Qué hace `normalize-indent.js`

Segunda pasada: dentro de los fences, los tabs del indent *relativo* pasan a 4 espacios cada uno (los tabs base de la lista se conservan — convención del vault). Evita `TabError` al copiar el código a Python. Ejecútala siempre después de la principal.

## Verificación posterior (obligatoria antes de dar por bueno)

```bash
# 1. Cero chunks de código residuales en líneas propias
grep -nP '^\s*(\*\*)?``.+(?<!`)``(\*\*)?[\s`º]*$' "nota.md" | grep -v '^\s*[0-9]*:\s*-'
# 2. Fences balanceados: el conteo de ``` debe ser par
grep -c '```' "nota.md"
# 3. Difiere contra el backup y lee muestras: indentación, ejemplos separados, bullets intactos
```

## Advertencias honestas

- El pegado original puede traer **indentación inconsistente** (ej. el cuerpo del código a 2 tabs y el chunk base a 3): el resultado hereda esa geometría — Python válido pero sobre-indentado. Si el usuario quiere indentación canónica, hay que rehacerla a mano o bloque a bloque.
- Si la nota tiene código de **varios lenguajes**, procesa por zonas o ajusta `LANG` por bloque; el script asume un solo lenguaje.
- En notas de muchos KB el diff será grande: hazlo en un commit propio o con el historial aplastado para no arrastrar basura.
