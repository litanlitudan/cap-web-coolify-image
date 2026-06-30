FROM ghcr.io/capsoftware/cap-web:latest
USER root
RUN set -eux; \
  echo '--- pwd ---'; pwd; \
  echo '--- root dirs ---'; ls -la / | sed -n '1,120p'; \
  echo '--- app-ish dirs ---'; find / -maxdepth 3 \( -name '.next' -o -name 'server.js' -o -name 'proxy.js' -o -name 'middleware.js' -o -name 'app' \) 2>/dev/null | sed -n '1,200p'; \
  echo '--- grep login/middleware/well-known candidates ---'; \
  grep -Rsl --include='*.js' -e '/login' -e '/middleware' -e 'verify-otp' /app /usr/src/app /var/task /home 2>/dev/null | sed -n '1,200p'; \
  echo '--- snippets ---'; \
  for f in $(grep -Rsl --include='*.js' -e 'verify-otp' -e '/middleware' /app /usr/src/app /var/task /home 2>/dev/null | head -20); do echo ===$f===; grep -n -E 'verify-otp|middleware|onboarding|self-hosting|download|terms|signup|invite' $f | head -20 || true; done; \
  exit 1
