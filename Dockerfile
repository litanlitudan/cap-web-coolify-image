FROM ghcr.io/capsoftware/cap-web:latest
USER root
RUN set -eux; \
  echo '--- proxy.ts ---'; sed -n '1,180p' /app/apps/web/proxy.ts; \
  echo '--- middleware.js ---'; sed -n '1,220p' /app/apps/web/.next/server/middleware.js; \
  echo '--- middleware manifest ---'; sed -n '1,220p' /app/apps/web/.next/server/middleware-manifest.json; \
  echo '--- workflow routes ---'; find /app/apps/web/.next/server/app/.well-known -maxdepth 5 -type f 2>/dev/null | sort | sed -n '1,200p'; \
  exit 1
