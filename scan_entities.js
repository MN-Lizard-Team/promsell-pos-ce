const fs = require('fs');
const path = require('path');
const root = 'd:\\Teepakorn-54850\\non-work\\promsell-pos-ce\\lib\\features';

function walk(dir, pattern) {
  const results = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) results.push(...walk(full, pattern));
    else if (entry.name.endsWith('.dart') && full.includes(pattern)) {
      const lines = fs.readFileSync(full, 'utf8').split('\n').length;
      results.push({ file: entry.name, lines, path: full.replace(root, '').replace(/\\/g, '/') });
    }
  }
  return results;
}

const entities = walk(root, 'domain\\entities').sort((a,b) => b.lines - a.lines);
console.log('=== Domain Entities (sorted by size) ===');
entities.slice(0, 15).forEach(e => console.log(e.lines.toString().padStart(3) + ' lines  ' + e.path));

const repos = walk(root, 'data\\repositories');
console.log('\n=== Data Repositories ===');
repos.forEach(r => console.log(r.lines.toString().padStart(3) + ' lines  ' + r.path));

const datasources = walk(root, 'data\\datasources');
console.log('\n=== Data Datasources ===');
datasources.forEach(d => console.log(d.lines.toString().padStart(3) + ' lines  ' + d.path));

const pages = walk(root, 'presentation\\pages');
console.log('\n=== Presentation Pages (largest) ===');
pages.sort((a,b) => b.lines - a.lines).slice(0, 10).forEach(p => console.log(p.lines.toString().padStart(3) + ' lines  ' + p.path));
