FROM ghcr.io/capsoftware/cap-web:latest

USER root

# Cap self-host fix:
# Allow Workflow DevKit control-plane routes through the self-host proxy.
# Patch both the source proxy.ts and the already-compiled Turbopack server chunk.
RUN node <<'NODE'
const fs = require('fs');
const path = require('path');

function patchFile(file, replacements) {
  let src = fs.readFileSync(file, 'utf8');
  let next = src;
  for (const [from, to] of replacements) next = next.replaceAll(from, to);
  if (next !== src) {
    fs.writeFileSync(file, next);
    console.log(`patched ${file}`);
    return true;
  }
  return false;
}

// Source file, useful for future debugging and if Cap changes startup behavior.
patchFile('/app/apps/web/proxy.ts', [[
  'path.startsWith("/middleware") ||',
  'path.startsWith("/middleware") ||\n\t\t\t\tpath.startsWith("/.well-known/workflow") ||',
]]);

// Compiled runtime chunk currently used by Next/Turbopack standalone output.
const roots = ['/app/apps/web/.next/server'];
let compiledPatched = 0;
function walk(dir) {
  for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, ent.name);
    if (ent.isDirectory()) walk(p);
    else if (ent.isFile() && p.endsWith('.js')) {
      if (patchFile(p, [
        ['n.startsWith("/middleware")||n.startsWith("/dashboard")', 'n.startsWith("/middleware")||n.startsWith("/.well-known/workflow")||n.startsWith("/dashboard")'],
        ['path.startsWith("/middleware")||path.startsWith("/dashboard")', 'path.startsWith("/middleware")||path.startsWith("/.well-known/workflow")||path.startsWith("/dashboard")'],
      ])) compiledPatched++;
    }
  }
}
for (const root of roots) walk(root);

if (compiledPatched === 0) {
  console.error('Patch verification failed: no compiled proxy chunk was patched.');
  process.exit(1);
}

let verified = false;
function verify(dir) {
  for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, ent.name);
    if (ent.isDirectory()) verify(p);
    else if (ent.isFile() && p.endsWith('.js')) {
      const s = fs.readFileSync(p, 'utf8');
      if (s.includes('startsWith("/.well-known/workflow")')) verified = true;
    }
  }
}
verify('/app/apps/web/.next/server');
if (!verified) {
  console.error('Patch verification failed: compiled server output does not contain /.well-known/workflow.');
  process.exit(1);
}
console.log(`Compiled proxy patch applied to ${compiledPatched} file(s).`);
NODE

RUN grep -Rsn 'well-known/workflow' /app/apps/web/proxy.ts /app/apps/web/.next/server/chunks 2>/dev/null | head -20

USER nextjs
