# Contribuir a obsidian-vault-kit

Gracias por tu interés. Convenciones del repo — léelas antes del primer PR.

## Reglas de oro

1. **Documentación en español**; identificadores, comandos y código en inglés.
2. **Sin marcas de terceros en la documentación ni en comentarios.** Los únicos
   lugares donde puede aparecer el nombre del ecosistema de origen son los
   archivos estructurales JSON cuando la convención de carga lo exige. El CI
   rechaza cualquier `.md` o comentario que mencione marcas ajenas.
3. **Nada en el prefijo global de npm.** Las dependencias CLI (`defuddle-cli`,
   `knap`) se instalan con pnpm *dentro* del plugin y se resuelven por ruta
   relativa. Borrar el plugin borra todo.
4. **Ningún archivo suelto en la raíz**: todo vive en su paquete o skill.
5. **Cada skill se prueba en un vault real** antes de proponer el cambio.

## Añadir o modificar una skill

1. Cada skill vive en `plugins/obsidian/skills/<nombre>/` con su `SKILL.md`
   (en mayúsculas, es el nombre que exige el cargador de skills) con
   frontmatter `name` y `description`.
2. Los scripts de la skill son autocontenidos (ESM/PowerShell) y detectan sus
   dependencias de sistema en tiempo de ejecución.
3. Si la skill añade dependencias CLI: actualiza `plugins/obsidian/package.json`
   y `pnpm-lock.yaml`, nunca instales a mano.
4. Actualiza `README.md` (sección Estructura) y añade entrada en `CHANGELOG.md`.

## Versionado

- La versión vive en `plugins/obsidian/plugin.json` y se incrementa con
  `scripts/bump.sh` (major/minor/patch).
- `marketplace.json` y `.agents/plugins/marketplace.json` deben reflejar la
  misma versión; el CI lo comprueba.
- Semántica: **major** = cambio incompatible en una skill o en la estructura;
  **minor** = skill nueva; **patch** = fix o documentación.

## Antes de abrir el PR

- `node -e "JSON.parse(require('fs').readFileSync('marketplace.json'))"` y el
  mismo chequeo sobre los demás JSON que toques.
- `git status` limpio de archivos que no correspondan al cambio.
- Describe qué probaste y en qué vault.
