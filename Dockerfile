FROM ghcr.io/capsoftware/cap-web:latest
USER root
RUN node <<'NODE'
const fs = require('fs');
const path = require('path');
const roots = ['/app/apps/web/.next/server', '/app/apps/web/server.js'];
const files = [];
function walk(p){
  if (!fs.existsSync(p)) return;
  const st = fs.statSync(p);
  if (st.isDirectory()) for (const e of fs.readdirSync(p)) walk(path.join(p,e));
  else if (st.isFile() && st.size < 5_000_000) files.push(p);
}
roots.forEach(walk);
for (const f of files) {
  let s; try { s = fs.readFileSync(f, 'utf8'); } catch { continue; }
  const score = ['/login','/dashboard','/verify-otp','/self-hosting','/middleware','NEXT_PUBLIC_IS_CAP','NextResponse.redirect'].filter(x=>s.includes(x)).length;
  if (score >= 3) {
    console.log('===', f, 'score', score, 'size', s.length);
    for (const needle of ['/middleware','/verify-otp','/self-hosting','NEXT_PUBLIC_IS_CAP','/login']) {
      const i = s.indexOf(needle);
      if (i >= 0) console.log('---', needle, '---\n' + s.slice(Math.max(0,i-500), Math.min(s.length,i+1200)).replace(/\n/g,'\\n'));
    }
  }
}
process.exit(1);
NODE
