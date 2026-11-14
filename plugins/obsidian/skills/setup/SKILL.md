---
name: setup
description: Verificar el tooling del que dependen las skills de este plugin — la CLI oficial de Obsidian, Node.js/pnpm, y los binarios enjaulados de defuddle y knap dentro del plugin. Úsala cuando la CLI de una skill falta o no funciona, cuando se pide configurar alguna de ellas, o antes del primer uso de defuddle, knap u obsidian-cli.
---

# Setup: tooling del plugin obsidian-vault-kit

Guía de verificación (y, con confirmación del usuario, de instalación) de las
dependencias del plugin. Nada aquí instala nada global: todo vive dentro del
propio plugin o viene con Obsidian.

## Componentes

### 1. CLI oficial de Obsidian (viene con la app, no se instala desde npm)

1. Comprobar: `obsidian version` (o `"/c/Program Files/Obsidian/Obsidian.com" version`
   en Windows Git Bash si no está en PATH; en WSL usar el redirector `Obsidian.com`).
2. Confirmar que la app está en ejecución — la CLI habla con la app viva.
3. `obsidian vaults` debe listar los vaults registrados.
4. Si no existe: guiar al usuario por Settings → General → Command line
   interface dentro de Obsidian (requiere installer 1.12.7+). Nunca instalar
   el paquete npm `obsidian-cli` — es otro proyecto y NO es este.

### 2. Node.js ≥ 20 y pnpm

1. `node --version` — debe ser ≥ 20 (requisito de knap).
2. `pnpm --version` — si falta: `npm install -g pnpm` o corepack, solo con
   confirmación expresa del usuario.

### 3. Binarios enjaulados: defuddle y knap

Las dependencias viven DENTRO del plugin: la raíz es dos niveles arriba de
cualquier `skills/<nombre>/`, y los binarios en `<raíz>/node_modules/.bin/`
(en Windows: `defuddle.cmd` / `knap.cmd`).

1. Verificar `<plugin-root>/node_modules/.bin/defuddle --help` y
   `<plugin-root>/node_modules/.bin/knap --help`.
2. Si falta `node_modules/`: pedir confirmación y ejecutar
   `cd <plugin-root> && pnpm install`.
3. Prohibido: `npm install -g defuddle|knap`, `npx`, o binarios sueltos del
   PATH — el inventario es el `package.json` del propio plugin.

## Reglas

- No afirmar que un componente está listo hasta que su comando de verificación
  pase de verdad.
- Instalar es consentimiento explícito: ofrecer siempre antes, nunca ejecutar
  instalaciones sin confirmación.
- Este setup no crea, modifica ni borra contenido de ningún vault.
