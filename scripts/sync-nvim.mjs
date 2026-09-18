// Generate thin destination templates; the actual configuration stays in config/nvim.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
for (const entry of fs.readdirSync(path.join(root, 'config/nvim'), { recursive: true, withFileTypes: true })) {
  if (!entry.isFile()) continue;
  const relative = path.relative(path.join(root, 'config/nvim'), path.join(entry.parentPath, entry.name)).split(path.sep).join('/');
  for (const target of ['home/dot_config/nvim', 'home/AppData/Local/nvim']) {
    const destination = path.join(root, target, relative + '.tmpl');
    fs.mkdirSync(path.dirname(destination), { recursive: true });
    fs.writeFileSync(destination, `{{- include (joinPath .chezmoi.sourceDir ".." ${JSON.stringify('config/nvim/' + relative)}) -}}\n`);
  }
}
