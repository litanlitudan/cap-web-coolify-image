FROM ghcr.io/capsoftware/cap-web:latest
USER root
RUN set -eux; \
  echo '--- workdir/user/cmd-ish ---'; pwd; id; \
  echo '--- /app tree ---'; find /app -maxdepth 5 -printf '%M %s %p\n' 2>/dev/null | sed -n '1,400p'; \
  echo '--- all js-ish files count/sample ---'; find / -type f \( -name '*.js' -o -name '*.mjs' -o -name '*.cjs' -o -name 'server' \) 2>/dev/null | sed -n '1,400p'; \
  echo '--- all files containing cap-web-ish names ---'; find / -maxdepth 5 -type f 2>/dev/null | grep -Ei 'next|server|proxy|middleware|package|start|entry|index' | sed -n '1,400p'; \
  echo '--- env PATH ---'; env | sort | sed -n '1,120p'; \
  exit 1
