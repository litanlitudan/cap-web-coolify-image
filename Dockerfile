FROM ghcr.io/capsoftware/cap-web:latest
USER root
RUN set -eux; \
  echo '--- pwd/user ---'; pwd; id; \
  echo '--- /app ls recursive ---'; ls -laR /app 2>/dev/null | sed -n '1,500p'; \
  echo '--- top dirs ---'; for d in /app /home /usr/src /var/task /opt; do echo ===$d===; find $d -maxdepth 4 -type f 2>/dev/null | sed -n '1,200p'; done; \
  echo '--- grep candidate strings anywhere except npm ---'; \
  find /app /home /usr/src /var/task /opt -type f 2>/dev/null | while read f; do case "$f" in *node_modules/npm*) continue;; esac; grep -Iq . "$f" && grep -qE '/login|verify-otp|/self-hosting|/dashboard/caps|well-known|workflow/v1' "$f" && echo "$f"; done | sed -n '1,300p'; \
  echo '--- snippets ---'; \
  for f in $(find /app /home /usr/src /var/task /opt -type f 2>/dev/null | head -10000); do grep -Iq . "$f" && grep -qE '/dashboard/caps|verify-otp|workflow/v1|/self-hosting' "$f" && { echo ===$f===; grep -nE '/dashboard/caps|verify-otp|workflow/v1|/self-hosting|/login|startsWith' "$f" | head -40; }; done; \
  exit 1
