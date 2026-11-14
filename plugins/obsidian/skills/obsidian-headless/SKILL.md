---
name: obsidian-headless
description: Sincroniza y publica vaults de Obsidian desde la línea de comandos con Obsidian Headless (`ob`), sin la app de escritorio. Usar cuando el usuario quiera configurar o ejecutar Obsidian Sync u Obsidian Publish en un servidor, en CI o desde una terminal, o cambiar la configuración de Sync o Publish de un vault.
---

# Obsidian Headless

Usa Obsidian Headless (`ob`) para ejecutar Obsidian Sync y Obsidian Publish desde la línea de comandos. No necesita la app de escritorio, así que funciona en servidores, en CI y en sandboxes. Está en beta abierta. Documentación: https://help.obsidian.md/headless

`ob` solo sincroniza y publica archivos. Para leer o modificar notas sin la app, edita los archivos directamente y sigue la skill obsidian-markdown. Para controlar una app de escritorio en ejecución, usa la skill obsidian-cli.

## Antes de usar ob

Verifica la disponibilidad con `ob --help`. Si falta, explica que Obsidian Headless requiere Node.js 22 o posterior y ofrece instalarlo con `npm install -g obsidian-headless`. Ejecuta `ob <command> --help` para ver las opciones de un comando.

Sync y Publish requieren cada uno una suscripción activa en la cuenta del usuario.

La mayoría de los comandos aceptan `--json` para una salida legible por máquinas.

## Iniciar sesión

`ob login` imprime la cuenta si ya hay sesión iniciada. De lo contrario, pide email, contraseña y un código 2FA, así que pide al usuario ejecutarlo en su propia terminal. No pidas su contraseña ni la pases con `--password`. `ob logout` borra las credenciales almacenadas.

## Rutas de vault

Los comandos actúan sobre el vault del directorio actual, o sobre el indicado con `--path`. Pasa `--path` para que el objetivo sea explícito. Antes de un comando que cambie el estado remoto, confirma el vault, el sitio y la ruta a partir de la salida de list o status.

## Sync

No uses el Sync de la app de escritorio y el Headless Sync para el mismo vault en el mismo dispositivo, porque generan conflictos. Pide al usuario que respalde la carpeta del vault antes de la primera sincronización.

```bash
ob sync-list-remote                                  # remote vaults, including shared ones
ob sync-list-local                                   # vaults set up on this machine
ob sync-setup --vault "Research" --path ~/vaults/research
ob sync --path ~/vaults/research                     # sync once
ob sync --path ~/vaults/research --continuous        # keep syncing as files change
ob sync-status --path ~/vaults/research
ob sync-unlink --path ~/vaults/research              # disconnect and remove stored credentials
```

`--vault` toma el nombre o el ID de un vault remoto. Para un vault con cifrado de extremo a extremo, `sync-setup` pide la contraseña de cifrado, así que deja que el usuario la introduzca. Configura `--device-name` para etiquetar esta máquina en el historial de versiones.

`--continuous` se ejecuta hasta que se detenga, así que inícialo en segundo plano o como un servicio.

`ob sync-create-remote --name "Research"` crea un vault remoto. Agrega `--encryption e2ee` para cifrado de extremo a extremo o `--encryption standard` para cifrado administrado.

### Configuración de Sync

`ob sync-config --path <vault>` imprime la configuración del vault. Cámbiala con:

- `--mode bidirectional|pull-only|mirror-remote`. `pull-only` ignora los cambios locales y `mirror-remote` los revierte, así que confirma antes de configurar cualquiera de los dos.
- `--conflict-strategy merge|conflict`
- `--excluded-folders "Archive,Templates"`
- `--file-types image,audio,video,pdf,unsupported` para los tipos de adjuntos a sincronizar.
- `--configs` para las categorías de configuración a sincronizar, p. ej. `app,appearance,core-plugin`.
- `--config-dir` cuando la carpeta de configuración del vault no sea `.obsidian`.

Una cadena vacía limpia una opción de lista, p. ej. `--excluded-folders ""`.

## Publish

```bash
ob publish-list-sites
ob publish-setup --site my-notes --path ~/vaults/research
ob publish --path ~/vaults/research --dry-run
ob publish --path ~/vaults/research --yes
```

`ob publish` incluye solo las notas con `publish: true` en sus properties. `--all` incluye todos los archivos, así que úsalo solo cuando el usuario lo pida. Ejecuta `--dry-run` primero y muéstrale al usuario los cambios. Sin `--yes`, `ob publish` espera una confirmación, así que pasa `--yes` una vez que el usuario apruebe, o para un trabajo desatendido que él haya configurado.

`ob publish-create-site --slug my-notes` crea un sitio en `publish.obsidian.md/my-notes`.

Ejecuta estos comandos sin opciones para imprimir la configuración actual:

- `ob publish-config` define las carpetas a incluir o excluir con `--includes` y `--excludes`.
- `ob publish-site-options` define el nombre del sitio, la página de inicio, la navegación, el tema y otras opciones de visualización. Ejecuta `ob publish-site-options --help` para la lista completa.

`ob publish-unlink` desconecta el vault de su sitio.
