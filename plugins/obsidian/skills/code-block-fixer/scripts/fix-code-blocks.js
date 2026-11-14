// fix-code-blocks.js — Convierte chunks ``...`` (posiblemente **``...``**) que forman bloques
// de código multi-línea en fences ```LANG, preservando indentación relativa.
// NO toca: chunks semánticos (Numpy, Abstracción...), chunks dentro de bullets "- ",
// líneas con un solo backtick, bloques fence existentes, código indentado sin backticks.
//
// Uso: node fix-code-blocks.js "P:\ruta\a\nota.md"     (haz backup antes)
import fs from 'fs';

const FILE = process.argv[2];
const LANG = 'python';   // cambia si la nota es de otro lenguaje
if (!FILE) { console.error('Uso: node fix-code-blocks.js "<ruta-de-nota.md>"'); process.exit(1); }

const src = fs.readFileSync(FILE, 'utf8');
const lines = src.split('\n');

// chunk completo de línea: ws + (**) + ``contenido`` + (**) + basura(espacios/backticks/º)
const CHUNK = /^(\s*)(\*\*)?``(.*)``(\*\*)?[\s`º]*$/;
const isChunk = (l) => {
  if (l.trim().startsWith('```')) return null;          // fence existente
  const m = l.match(CHUNK);
  if (!m) return null;
  if (/^\s*-\s/.test(l)) return null;                    // bullet de lista: no tocar
  const content = m[3].replace(/\s+$/, '').replace(/^\s+/, '');
  if (!content) return null;                             // `` vacío
  return { ws: m[1], content };
};
const isBlank = (l) => l.trim() === '';

const out = [];
let run = [];          // {ws, content}
let pendingBlanks = 0;

function flush() {
  if (!run.length) { for (let i = 0; i < pendingBlanks; i++) out.push(''); pendingBlanks = 0; return; }
  const base = run[0].ws;
  out.push(base + '```' + LANG);
  run.forEach((c) => {
    const rel = c.ws.startsWith(base) ? c.ws.slice(base.length) : c.ws;
    out.push(base + rel + c.content);
  });
  out.push(base + '```');
  run = [];
  for (let i = 0; i < pendingBlanks; i++) out.push('');
  pendingBlanks = 0;
}

for (const line of lines) {
  const ch = isChunk(line);
  if (ch) {
    // separador semántico: def/class a nivel superior dentro de un run ya iniciado
    if (run.length && /^(def|class)\s/.test(ch.content)) flush();
    for (let i = 0; i < pendingBlanks; i++) run.push({ ws: run.length ? run[run.length-1].ws : ch.ws, content: '' });
    pendingBlanks = 0;
    run.push(ch);
  } else if (isBlank(line)) {
    if (run.length) pendingBlanks++;
    else { flush(); out.push(''); }   // flush de pendientes fuera de run
  } else {
    flush();
    out.push(line);
  }
}
flush();

fs.writeFileSync(FILE, out.join('\n'), 'utf8');
console.log('Líneas antes:', lines.length, '| después:', out.length);
