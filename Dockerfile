FROM ghcr.io/capsoftware/cap-web:latest
USER root
RUN set -eux; \
  echo '--- binaries ---'; which node; node -v; which npm; npm -v; which pnpm || true; which corepack || true; \
  echo '--- root/package files ---'; ls -la /app | sed -n '1,120p'; find /app -maxdepth 2 -name 'package.json' -o -name 'pnpm-lock.yaml' -o -name 'pnpm-workspace.yaml' -o -name 'turbo.json' | sort; \
  echo '--- app package scripts ---'; sed -n '1,80p' /app/apps/web/package.json; \
  exit 1
