const { execSync } = require('child_process');
const path = require('path');

const E   = String.fromCharCode(27);
const R   = E + '[0m';
const DIM = E + '[2m';
const SAGE = E + '[38;2;135;160;140m';
const GOLD = E + '[38;2;210;195;130m';
const MRED = E + '[38;2;160;90;85m';
const CYN  = E + '[38;2;100;150;160m';
const PUR  = E + '[38;2;140;120;165m';
const BLU  = E + '[38;2;100;140;170m';
const SEP  = ' ' + DIM + '|' + R + ' ';

function bar(p) {
  const w = 8, f = Math.round(p / 100 * w);
  return '█'.repeat(f) + '░'.repeat(w - f);
}
function bc(p)  { return p < 60 ? SAGE : p < 85 ? GOLD : MRED; }
function rt(ts) { const d = new Date(ts * 1000); return String(d.getHours()).padStart(2,'0') + ':' + String(d.getMinutes()).padStart(2,'0'); }
function rd(ts) { const d = new Date(ts * 1000); return ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][d.getMonth()] + ' ' + d.getDate(); }

let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  try {
    const j = JSON.parse(input || '{}');
    const folder = path.basename(j.cwd || process.cwd());

    let branch = '';
    try {
      branch = execSync('git rev-parse --abbrev-ref HEAD', { encoding: 'utf8', stdio: 'pipe' }).trim();
      if (branch === 'HEAD') branch = '';
    } catch (e) {}

    const fp = j.rate_limits?.five_hour?.used_percentage;
    const fr = j.rate_limits?.five_hour?.resets_at;
    const sp = j.rate_limits?.seven_day?.used_percentage;
    const sr = j.rate_limits?.seven_day?.resets_at;
    const cp = j.context_window?.used_percentage;
    const model        = j.model?.display_name || 'Claude';
    const linesAdded   = j.cost?.total_lines_added || 0;
    const linesRemoved = j.cost?.total_lines_removed || 0;

    const offset = -(new Date().getTimezoneOffset()) / 60;
    const hh = String(new Date().getHours()).padStart(2, '0');
    const mm = String(new Date().getMinutes()).padStart(2, '0');
    const tz = offset >= 8 ? 'TPE' : offset >= 7 ? 'BKK' : 'GMT' + (offset >= 0 ? '+' : '') + offset;

    // Line 1: folder + branch + rate limits
    let line1 = CYN + '🍕 ~/…/' + folder + R;
    if (branch) line1 += SEP + CYN + '🐼 ' + branch + R;
    if (fp != null) {
      line1 += SEP + DIM + '5h ' + R + bc(fp) + bar(fp) + R + ' ' + bc(fp) + Math.round(fp) + '%' + R;
      if (fr) line1 += '  ' + DIM + '↺ ' + rt(fr) + R;
    }
    if (sp != null) {
      line1 += SEP + DIM + '7d ' + R + bc(sp) + bar(sp) + R + ' ' + bc(sp) + Math.round(sp) + '%' + R;
      if (sr) line1 += '  ' + DIM + '↺ ' + rd(sr) + R;
    }

    // Line 2: model + context + lines + time
    let line2 = PUR + '🤖 ' + model + R;
    if (cp != null) line2 += SEP + '🎨 ' + BLU + Math.round(cp) + '%' + R;
    if (linesAdded   > 0) line2 += '  ' + SAGE + '+' + linesAdded + R;
    if (linesRemoved > 0) line2 += '  ' + MRED + '-' + linesRemoved + R;
    line2 += SEP + DIM + tz + ' ' + hh + ':' + mm + R;

    process.stdout.write(line1 + '\n' + line2 + '\n');
  } catch (e) {
    process.stdout.write('🍕 err');
  }
});
