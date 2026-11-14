# Referencia de properties (frontmatter)

Las properties usan YAML frontmatter al inicio de una nota:

```yaml
---
title: My Note Title
date: 2024-01-15
tags:
  - project
  - important
aliases:
  - My Note
  - Alternative Name
cssclasses:
  - custom-class
status: in-progress
rating: 4.5
completed: false
due: 2024-02-01T14:30:00
---
```

## Tipos de property

| Type | Example |
|------|---------|
| Text | `title: My Title` |
| Number | `rating: 4.5` |
| Checkbox | `completed: true` |
| Date | `date: 2024-01-15` |
| Date & Time | `due: 2024-01-15T14:30:00` |
| List | `tags: [one, two]` or YAML list |
| Tags | Only for the `tags` property |

Los enlaces van en properties de tipo Text o List: `related: "[[Other Note]]"`. Escapa siempre los wikilinks entre comillas en YAML, porque un `[[Other Note]]` sin comillas se interpreta como una lista anidada, no como un enlace.

## Properties por defecto

- `tags` - Tags de la nota (buscables, se muestran en la vista de grafo)
- `aliases` - Nombres alternativos para la nota, ofrecidos en las sugerencias de enlaces. Un `[[Alias]]` solo no se resuelve; escribe `[[Note|Alias]]`
- `cssclasses` - Clases CSS aplicadas a la nota en la vista de lectura/edición

## Tags

```markdown
#tag
#nested/tag
#tag-with-dashes
#tag_with_underscores
```

Los tags pueden contener: letras (en cualquier idioma), números, guiones bajos `_`, guiones `-`, barras diagonales `/` (para anidar). Un tag necesita al menos un carácter no numérico (`#1984book`, no `#1984`), y un espacio lo termina.

En el frontmatter:

```yaml
---
tags:
  - tag1
  - nested/tag2
---
```
