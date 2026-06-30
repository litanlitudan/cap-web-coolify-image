FROM ghcr.io/capsoftware/cap-web:latest
USER root
RUN set -eux; \
  echo '--- grep -a dashboard/caps ---'; grep -Rasn 'dashboard/caps' /app/apps/web/.next /app/apps/web/server.js 2>/dev/null | sed -n '1,120p'; \
  echo '--- grep -a /middleware ---'; grep -Rasn '/middleware' /app/apps/web/.next /app/apps/web/server.js 2>/dev/null | sed -n '1,120p'; \
  echo '--- grep -a verify-otp ---'; grep -Rasn 'verify-otp' /app/apps/web/.next /app/apps/web/server.js 2>/dev/null | sed -n '1,120p'; \
  echo '--- grep -a NEXT_PUBLIC_IS_CAP ---'; grep -Rasn 'NEXT_PUBLIC_IS_CAP\|path.startsWith' /app/apps/web/.next /app/apps/web/server.js 2>/dev/null | sed -n '1,200p'; \
  exit 1
