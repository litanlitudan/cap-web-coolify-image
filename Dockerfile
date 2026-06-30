FROM ghcr.io/capsoftware/cap-web:latest
USER root
RUN set -eux; \
  echo '--- grep dashboard/caps ---'; grep -Rsn --include='*.js' 'dashboard/caps' /app/apps/web/.next/server /app/apps/web/.next/static /app/apps/web 2>/dev/null | sed -n '1,120p'; \
  echo '--- grep /middleware ---'; grep -Rsn --include='*.js' '/middleware' /app/apps/web/.next/server /app/apps/web/.next/static /app/apps/web 2>/dev/null | sed -n '1,120p'; \
  echo '--- grep verify-otp ---'; grep -Rsn --include='*.js' 'verify-otp' /app/apps/web/.next/server /app/apps/web/.next/static /app/apps/web 2>/dev/null | sed -n '1,120p'; \
  echo '--- grep redirect login ---'; grep -Rsn --include='*.js' 'redirect(new URL(.*login\|/login' /app/apps/web/.next/server/chunks /app/apps/web/.next/server/edge/chunks 2>/dev/null | sed -n '1,200p'; \
  exit 1
