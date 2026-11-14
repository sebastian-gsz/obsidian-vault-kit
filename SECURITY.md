# Política de seguridad

## Reportar una vulnerabilidad

Si encuentras un fallo de seguridad en este plugin o en sus scripts, **no abras
un issue público**. Usa la pestaña *Security → Report a vulnerability* de GitHub
o escribe al maintainer listado en el perfil de la organización. Responderemos
en un máximo de 72 horas y trabajaremos el fix en privado antes de publicarlo.

## Superficie de riesgo conocida

- **Binarios enjaulados**: `defuddle-cli` y `knap` se instalan desde el registro
  npm con pnpm y quedan fijados por `pnpm-lock.yaml` dentro de
  `plugins/obsidian/`. Se ejecutan como proceso local del usuario. Para auditar:
  `pnpm audit` dentro de `plugins/obsidian/` y comparar el lockfile contra el
  registro oficial.
- **Scripts de skills**: los `.sh`/`.ps1` son autocontenidos y no descargan
  código de la red en tiempo de ejecución. Cualquier cambio que introduzca una
  descarga debe justificarse en el PR y pasar revisión manual.
- **Permisos del vault**: las skills escriben solo dentro del vault configurado;
  `image-optimizer` crea los respaldos de originales *fuera* del vault, en la
  ruta que indiques en cada invocación.

## Buenas prácticas al usar el plugin

- Revisa los diffs de tus notas tras ejecutar skills de transformación
  (`knap`, `code-block-fixer`, `image-optimizer`): tu vault está en git, es tu
  red de seguridad.
- No pegues secretos ni tokens en notas que las skills puedan procesar.
