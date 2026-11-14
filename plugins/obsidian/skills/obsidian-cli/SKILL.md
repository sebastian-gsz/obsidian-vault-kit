---
name: obsidian-cli
description: Interactúa con vaults de Obsidian usando el Obsidian CLI para leer, crear, buscar y administrar notas, tasks, properties y más. También permite desarrollar plugins y temas con comandos para recargar plugins, ejecutar JavaScript, capturar errores, tomar capturas de pantalla e inspeccionar el DOM. Usar cuando el usuario pida interactuar con su vault de Obsidian, administrar notas, buscar contenido del vault, realizar operaciones del vault desde la línea de comandos, o desarrollar y depurar plugins y temas de Obsidian.
---

# Obsidian CLI

Usa el CLI `obsidian` para interactuar con una instancia de Obsidian en ejecución. Requiere que Obsidian esté abierto.

## Antes de usar el CLI

Ejecuta `obsidian help` para verificar la disponibilidad. Si el comando no existe, explica cómo activar el CLI usando https://help.obsidian.md/cli. El comando `obsidian` viene incluido con el instalador de Obsidian; no instales el paquete npm no relacionado `obsidian-cli`. Si no encuentra Obsidian, pide al usuario que abra la app de escritorio y reintenta. En un shell con sandbox, el mismo mensaje puede significar que el sandbox bloqueó el socket local del CLI.

En WSL, ejecuta `Obsidian.com` desde la carpeta de instalación de Windows, no `Obsidian.exe`. `Obsidian.com` es el wrapper de consola que imprime la salida; `Obsidian.exe` termina sin imprimir nada.

El CLI sale con estado 0 incluso cuando un comando falla, así que lee su salida antes de informar que un comando tuvo éxito.

Escribe los parámetros entre comillas según el shell actual, y pasa el texto de las notas como datos de argumento literales, nunca como sintaxis de shell ejecutable.

## Referencia de comandos

Ejecuta `obsidian help` para ver todos los comandos disponibles. Está siempre actualizado. Documentación completa: https://help.obsidian.md/cli

## Sintaxis

**Parameters** toman un valor con `=`. Escribe entre comillas los valores con espacios:

```bash
obsidian create name="My Note" content="Hello world"
```

**Flags** son interruptores booleanos sin valor:

```bash
obsidian create name="My Note" open overwrite
```

Usa `overwrite` solo cuando se pretenda reemplazar un archivo existente.

Abrir es opcional (opt-in): pasa `open` para abrir el archivo, y agrega `newtab` para abrirlo en una nueva pestaña. No existe un flag `silent`.

En `content=`, `\n` se convierte en un salto de línea y `\t` en una tabulación. Cada `\n` y `\t` se convierte y no hay forma de escaparlo, por lo que texto como el LaTeX `\theta` o la ruta `C:\notes` se corrompe. Escribe directamente al archivo de la nota el contenido que contenga barras invertidas o que supere unos 4 KB.

Un punto en un nombre de archivo se interpreta como el inicio de una extensión. Cuando un nombre contiene un punto, incluye la extensión: `create name="Meeting 2026.11.06.md"`, `rename name="v1.2 notes.md"`, `move to="Archive 2026.10/Note.md"`.

## Apuntar a archivos

Muchos comandos aceptan `file` o `path` para apuntar a un archivo. Sin ninguno de los dos, se usa el archivo activo.

- `file=<name>` — resuelve como un wikilink (solo nombre, no se necesita ruta). `.md` es opcional; otros tipos de archivo necesitan su extensión, p. ej. `file="Projects.base"`. Los aliases no se resuelven.
- `path=<path>` — ruta exacta desde la raíz del vault, p. ej. `folder/note.md`

## Apuntar a vaults

Sin `vault=`, los comandos apuntan al vault que contiene el directorio actual, y luego al vault enfocado más recientemente. `vault=<name>` solo funciona como primer parámetro; en cualquier otra posición se ignora:

```bash
obsidian vault="My Vault" search query="test"
```

Usa `vault=` cuando el usuario haya seleccionado un vault. Si el objetivo no está claro y el usuario tiene varios vaults, pregunta cuál antes de modificar archivos.

## Patrones comunes

```bash
obsidian read file="My Note"
obsidian create name="New Note" template="Template"   # a template replaces content=
obsidian create name="New Note" content="# Hello" open  # also open in Obsidian
obsidian append file="My Note" content="New line"
obsidian rename path="folder/note.md" name="New name"
obsidian move path="folder/note.md" to="archive/"
obsidian delete path="folder/note.md"
obsidian search query="search term" limit=10
obsidian daily:read
obsidian daily:append content="- [ ] New task"
obsidian property:set name="status" value="done" file="My Note"
obsidian tasks daily todo
obsidian tags sort=count counts
obsidian backlinks file="My Note"
```

Usa `rename` y `move`, no el `mv` del sistema de archivos ni `obsidian eval`, para que Obsidian pueda actualizar los enlaces al archivo. Si otras notas enlazan a él y Settings → Files and links → Automatically update internal links está desactivado, Obsidian pregunta en un diálogo y el comando espera hasta que alguien responda. `delete` mueve el archivo a la papelera; no pases `permanent` a menos que el usuario lo pida. Prefiere `create` y `append` sobre `eval` para escribir el cuerpo de las notas.

Usa `total` en los comandos de lista para obtener un conteo.

**Ubicación de las opciones de salida:** `--copy`, `--json`, `--md`, `--tsv` y `--csv` solo funcionan **después** del nombre del comando. Colocarlas antes del comando (o antes de `vault=`) falla — a menudo como `Command "--copy" not found` — porque el primer token se trata como el comando. Prefiere `vault=` primero cuando se use; pon las opciones de doble guion al final:

```bash
obsidian tasks todo total --copy
obsidian vault="My Vault" search query="TODO" --copy
obsidian tasks todo format=json   # many list commands also accept format=
# Wrong: obsidian --copy vault="My Vault" tasks todo
```

## Desarrollo de plugins

### Ciclo de desarrollo/pruebas

Activa la captura de consola una vez con `obsidian dev:debug on`, para que se conserven los mensajes de la recarga. Tras hacer cambios de código en un plugin o tema, sigue este flujo de trabajo:

1. **Recarga** el plugin para aplicar los cambios:
   ```bash
   obsidian plugin:reload id=my-plugin
   ```
2. **Busca errores** — si aparecen errores, corrígelos y repite desde el paso 1:
   ```bash
   obsidian dev:errors
   ```
3. **Verifica visualmente** con una captura de pantalla o una inspección del DOM:
   ```bash
   obsidian dev:screenshot
   obsidian dev:dom selector=".workspace-leaf" text
   ```
4. **Revisa la salida de consola** en busca de advertencias o logs inesperados:
   ```bash
   obsidian dev:console level=error
   ```

`dev:screenshot` guarda en un archivo temporal e imprime su ruta. Un `path=` relativo guarda dentro del vault.

### Comandos adicionales para desarrolladores

Ejecuta JavaScript en el contexto de la app (prefiere los comandos dedicados como `rename`, `move`, `create` y `append` para mutaciones del vault):

```bash
obsidian eval code="app.vault.getFiles().length"
```

Inspecciona valores de CSS:

```bash
obsidian dev:css selector=".workspace-leaf" prop=background-color
```

Alterna la emulación móvil:

```bash
obsidian dev:mobile on
```

Ejecuta `obsidian help` para ver comandos adicionales para desarrolladores, incluidos los controles de CDP y el depurador.
