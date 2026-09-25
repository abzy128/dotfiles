// Regenerate the Windows Neovim tree as thin templates over home/dot_config/nvim,
// which holds the real files so `chezmoi re-add` works on Linux and macOS.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const source = path.join(root, 'home/dot_config/nvim');
const windows = path.join(root, 'home/AppData/Local/nvim');
fs.rmSync(windows, { recursive: true, force: true });
for (const entry of fs.readdirSync(source, { recursive: true, withFileTypes: true })) {
  if (!entry.isFile()) continue;
  const relative = path.relative(source, path.join(entry.parentPath, entry.name)).split(path.sep).join('/');
  if (relative.endsWith('.tmpl')) throw new Error(`${relative}: templates cannot be shared with Windows`);
  // Reusing the source name keeps chezmoi attributes such as dot_ and executable_.
  const destination = path.join(windows, relative + '.tmpl');
  fs.mkdirSync(path.dirname(destination), { recursive: true });
  fs.writeFileSync(destination, `{{- include ${JSON.stringify('dot_config/nvim/' + relative)} -}}\n`);
}
