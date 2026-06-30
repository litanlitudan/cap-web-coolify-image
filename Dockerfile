FROM ghcr.io/capsoftware/cap-web:latest
USER root
RUN node <<'NODE'
const fs = require('fs');
const path = require('path');
const roots = ['/app/apps/web/.next/server/chunks', '/app/apps/web/.next/server/edge/chunks', '/app/apps/web/server.js'];
const files = [];
function walk(p){
  if (!fs.existsSync(p)) return;
  const st = fs.statSync(p);
  if (st.isDirectory()) for (const e of fs.readdirSync(p)) walk(path.join(p,e));
  else if (st.isFile() && /\.js$/.test(p) && st.size < 5_000_000) files.push(p);
}
roots.forEach(walk);
for (const f of files) {
  let s; try { s = fs.readFileSync(f, 'utf8'); } catch { continue; }
  const needles = ['/login','/dashboard','/verify-otp','/self-hosting','/middleware','NEXT_PUBLIC_IS_CAP','redirect(new URL'];
  const hits = needles.filter(x=>s.includes(x));
  if (hits.length >= 3) {
    console.log('===', f, 'hits', hits.join(','), 'size', s.length);
    const i = Math.max(...hits.map(h => s.indexOf(h)).filter(i => i >= 0));
    console.log(s.slice(Math.max(0,i-1000), Math.min(s.length,i+2200)).replace(/\n/g,'\\n'));
  }
}
process.exit(1);
NODE
