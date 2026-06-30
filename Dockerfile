FROM ghcr.io/capsoftware/cap-web:latest

USER root

# Cap self-host fix:
# The web proxy allowlist must let Workflow DevKit control-plane calls through.
# Without this, POST /.well-known/workflow/v1/{flow,step} can be redirected
# to /login and silently return HTML 200, leaving uploads stuck at muxing.
RUN node <<'NODE'
const fs = require('fs');
const path = require('path');

const roots = ['/app', '/usr/src/app', '/var/task'];
const exts = new Set(['.js', '.mjs', '.cjs']);
const needles = [
  'path.startsWith("/middleware")||',
  'path.startsWith("/middleware") ||',
  "path.startsWith('/middleware')||",
  "path.startsWith('/middleware') ||",
];
const insertDouble = 'path.startsWith("/.well-known/workflow")||';
const insertDoubleSpaced = 'path.startsWith("/.well-known/workflow") ||';
const insertSingle = "path.startsWith('/.well-known/workflow')||";
const insertSingleSpaced = "path.startsWith('/.well-known/workflow') ||";

function walk(dir, out = []) {
  if (!fs.existsSync(dir)) return out;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (!['node_modules', '.git', 'cache'].includes(entry.name)) walk(p, out);
    } else if (entry.isFile() && exts.has(path.extname(entry.name))) {
      out.push(p);
    }
  }
  return out;
}

let patched = [];
for (const file of roots.flatMap((r) => walk(r))) {
  let src;
  try { src = fs.readFileSync(file, 'utf8'); } catch { continue; }
  if (!src.includes('/middleware') || !src.includes('/login')) continue;
  let next = src;
  next = next.replaceAll(needles[0], needles[0] + insertDouble);
  next = next.replaceAll(needles[1], needles[1] + insertDoubleSpaced);
  next = next.replaceAll(needles[2], needles[2] + insertSingle);
  next = next.replaceAll(needles[3], needles[3] + insertSingleSpaced);
  if (next !== src) {
    fs.writeFileSync(file, next);
    patched.push(file);
  }
}

if (patched.length === 0) {
  console.error('Failed to patch Cap proxy allowlist: could not find compiled path.startsWith("/middleware") marker.');
  process.exit(1);
}

console.log('Patched Cap proxy allowlist in:');
for (const f of patched) console.log(`- ${f}`);
NODE

# Optional build-time sanity: compiled output should now contain the allowlist entry.
RUN grep -R "/.well-known/workflow" -n /app /usr/src/app /var/task 2>/dev/null | head -20
