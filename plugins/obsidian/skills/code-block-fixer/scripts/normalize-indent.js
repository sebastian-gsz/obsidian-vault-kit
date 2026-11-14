// normalize-indent.js — segunda pasada tras fix-code-blocks.js: dentro de fences ```LANG,
// los tabs del indent RELATIVO pasan a 4 espacios cada uno (los tabs base del fence, que
// suelen ser la indentación de lista del vault, se conservan). Evita TabError al copiar.
//
// Uso: node normalize-indent.js "P:\ruta\a\nota.md"
import fs from 'fs';

const FILE = process.argv[2];
if (!FILE) { console.error('Uso: node normalize-indent.js "<ruta-de-nota.md>"'); process.exit(1); }

const lines = fs.readFileSync(FILE, 'utf8').split('\n');
let base = null, fixed = 0;
const out = lines.map((l) => {
  const m = l.match(/^(\t*)```/);
  if (m) { base = m[1]; return l; }          // apertura o cierre de fence: actualiza base
  if (base !== null && l.startsWith(base)) {
    const rel = l.slice(base.length);
    if (/\t/.test(rel)) { fixed++; return base + rel.replace(/\t/g, '    '); }
  }
  return l;
});
fs.writeFileSync(FILE, out.join('\n'), 'utf8');
console.log('lineas normalizadas:', fixed);
