FROM ghcr.io/capsoftware/cap-web:latest

USER root

# Cap self-host fix:
# Allow Workflow DevKit control-plane routes through the self-host proxy.
# Rebuild Next output so the compiled proxy/middleware uses the patched source.
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

console.log(`Patched ${file}: added /.well-known/workflow to self-host proxy allowlist.`);
NODE

RUN cd /app/apps/web && pnpm build
RUN grep -Rsn 'well-known/workflow' /app/apps/web/proxy.ts /app/apps/web/.next/server 2>/dev/null | head -20

USER nextjs
