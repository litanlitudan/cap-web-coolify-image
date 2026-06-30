FROM ghcr.io/capsoftware/cap-web:latest
USER root
RUN set -eux; \
  echo '--- server files with NEXT_PUBLIC_IS_CAP ---'; grep -Rasl 'NEXT_PUBLIC_IS_CAP' /app/apps/web/.next/server /app/apps/web/server.js 2>/dev/null | sed -n '1,120p'; \
  echo '--- snippets NEXT_PUBLIC_IS_CAP ---'; for f in $(grep -Rasl 'NEXT_PUBLIC_IS_CAP' /app/apps/web/.next/server /app/apps/web/server.js 2>/dev/null); do echo ===$f===; grep -asn -C 2 'NEXT_PUBLIC_IS_CAP' "$f" | head -80; done; \
  echo '--- server files with /verify-otp ---'; grep -Rasl 'verify-otp' /app/apps/web/.next/server /app/apps/web/server.js 2>/dev/null | sed -n '1,120p'; \
  echo '--- server files with /login redirect URL ---'; grep -Rasl '/login' /app/apps/web/.next/server/chunks /app/apps/web/server.js 2>/dev/null | sed -n '1,120p'; \
  exit 1
