FROM ghcr.io/capsoftware/cap-web:latest

USER root

# Cap self-host fix:
# Allow Workflow DevKit control-plane routes through the self-host proxy.
# Without this, POST /.well-known/workflow/v1/{flow,step} can be redirected
# to /login and silently return HTML 200, leaving uploads stuck at muxing.
RUN node <<'NODE'
const fs = require('fs');
const file = '/app/apps/web/proxy.ts';
let src = fs.readFileSync(file, 'utf8');

if (!src.includes('path.startsWith("/.well-known/workflow")')) {
  const marker = 'path.startsWith("/middleware") ||';
  if (!src.includes(marker)) {
    console.error(`Could not find proxy allowlist marker in ${file}`);
    process.exit(1);
  }
  src = src.replace(
    marker,
    `${marker}\n\t\t\t\tpath.startsWith("/.well-known/workflow") ||`,
  );
  fs.writeFileSync(file, src);
}

const patched = fs.readFileSync(file, 'utf8');
if (!patched.includes('path.startsWith("/.well-known/workflow")')) {
  console.error('Patch verification failed: workflow allowlist entry missing.');
  process.exit(1);
}
console.log(`Patched ${file}: added /.well-known/workflow to self-host proxy allowlist.`);
NODE

RUN grep -n 'well-known/workflow' /app/apps/web/proxy.ts

USER nextjs
