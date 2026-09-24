import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'dotfiles-check-'));
const destination = path.join(temp, 'home');
fs.mkdirSync(destination);
fs.writeFileSync(path.join(temp, 'chezmoi.toml'), '');

function run(command, args) {
  const result = spawnSync(command, args, { encoding: 'utf8', maxBuffer: 8 * 1024 * 1024 });
  if (result.error) throw result.error;
  return result;
}

function render(hostname, platform, extra = {}, command = ['dump', '--format=json', '--exclude=dirs']) {
  return run('chezmoi', [
    '--source', root, '--destination', destination,
    '--config', path.join(temp, 'chezmoi.toml'),
    '--persistent-state', path.join(temp, 'state.boltdb'),
    '--cache', path.join(temp, 'cache'), '--no-tty',
    '--override-data', JSON.stringify({ chezmoi: { hostname, os: platform, homeDir: destination }, ...extra }),
    ...command,
  ]);
}

function successful(result) {
  assert.equal(result.status, 0, result.stderr);
  return result.stdout;
}

function absent(tree, prefix) {
  assert(!Object.keys(tree).some(p => p === prefix || p.startsWith(prefix + '/')), `${prefix} must be excluded`);
}

function subtree(tree, prefix) {
  return Object.fromEntries(Object.entries(tree)
    .filter(([p]) => p.startsWith(prefix + '/'))
    .map(([p, e]) => [p.slice(prefix.length + 1), e.contents]));
}

let unixNvim;
try {
  const cases = [
    ['bts-n0298', 'linux', 'workstation', false],
    ['abzy-linux', 'linux', 'workstation', false],
    ['abzy-pn41', 'linux', 'server', true],
    ['abzy-m5', 'darwin', 'workstation', false],
    ['abzy-rog', 'windows', 'workstation', true],
  ];
  for (const [host, platform, type, git] of cases) {
    const tree = JSON.parse(successful(render(host, platform)));
    for (const p of ['.zshrc', '.zshenv', '.zsh', 'archive', 'config', 'vendor', 'AGENTS.md', 'README.md']) absent(tree, p);
    assert.equal(Boolean(tree['.gitconfig']), git, `${host}: Git ownership`);
    assert.equal(Boolean(tree['.gitconfig-work']), git);
    absent(tree, '.local/bin/updateGrub');
    absent(tree, '.local/bin/switchgpu');
    const nvim = subtree(tree, platform === 'windows' ? 'AppData/Local/nvim' : '.config/nvim');
    assert(nvim['init.lua'], `${host}: Neovim must be deployed`);
    if (platform === 'windows') assert.deepEqual(nvim, unixNvim, 'Windows Neovim must match Linux/macOS; run node scripts/sync-nvim.mjs');
    else unixNvim ??= nvim;
    if (platform === 'windows') {
      absent(tree, '.config');
      absent(tree, '.local');
      assert(tree['Documents/PowerShell/Microsoft.PowerShell_profile.ps1']);
      assert(tree['Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1']);
      assert(!Object.values(tree).some(e => e.type === 'symlink'), 'Windows must not require symlink privileges');
      assert.match(tree['.gitconfig'].contents, /gitdir\/i:~\/dev\/bts\//);
      const gitFile = path.join(temp, 'gitconfig');
      fs.writeFileSync(gitFile, tree['.gitconfig'].contents);
      assert.equal(successful(run('git', ['config', '--file', gitFile, 'init.defaultBranch'])).trim(), 'dev');
      fs.writeFileSync(path.join(temp, 'profile.ps1'), tree['Documents/PowerShell/Microsoft.PowerShell_profile.ps1'].contents);
    } else {
      absent(tree, 'AppData');
      absent(tree, 'Documents');
      const zellij = tree['.config/zellij/config.kdl'].contents;
      if (platform === 'darwin') {
        assert.match(zellij, /^copy_command "pbcopy"$/m);
        assert(!/^copy_command "wl-copy"/m.test(zellij));
        assert(!tree['.config/yazi/yazi.toml'].contents.includes('wl-copy'));
      }
      if (type === 'server') {
        for (const app of ['ghostty', 'hypr', 'waybar', 'rofi', 'cava', 'zed', 'yazi']) absent(tree, `.config/${app}`);
        absent(tree, '.local/bin');
        assert(!/^copy_command /m.test(zellij), 'server clipboard must not depend on Wayland');
      } else if (platform === 'linux') {
        assert(tree['.config/hypr/hyprland.lua']);
        assert(tree['.local/bin/ncalayer']);
        assert.match(zellij, /^copy_command "wl-copy"$/m);
      }
    }
    successful(render(host, platform, {}, ['apply', '--dry-run']));
    console.log(`PASS ${host}: ${Object.keys(tree).length} files/links, correct paths and ownership`);
  }

  // Host override selects a known machine; host feature overrides beat type defaults.
  const overridden = JSON.parse(successful(render('unknown', 'darwin', {
    machine: 'abzy-m5', hosts: { 'abzy-m5': { features: { nvim: false } } },
  })));
  absent(overridden, '.config/nvim');
  const nonNix = JSON.parse(successful(render('test-linux', 'linux', {
    hosts: { 'test-linux': { type: 'server', os: 'linux', nix: false, gitOwner: 'chezmoi' } },
  })));
  assert(nonNix['.gitconfig']);
  const invalid = [
    ['unknown', 'linux', {}, /Unknown host/],
    ['abzy-rog', 'linux', {}, /expects windows/],
    ['abzy-m5', 'darwin', { hosts: { 'abzy-m5': { type: 'typo' } } }, /Unknown host type/],
    ['abzy-m5', 'darwin', { hosts: { 'abzy-m5': { features: { nvm: true } } } }, /Unknown feature/],
    ['abzy-m5', 'darwin', { hosts: { 'abzy-m5': { features: { nvim: 'yes' } } } }, /must be a boolean/],
    ['abzy-rog', 'windows', { hosts: { 'abzy-rog': { gitOwner: 'home-manager' } } }, /requires a Nix host/],
    ['bts-n0298', 'linux', { hosts: { 'bts-n0298': { features: { legacyHardwareScripts: true } } } }, /not supported on Nix/],
  ];
  for (const [host, platform, data, error] of invalid) {
    const result = render(host, platform, data);
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, error);
  }
  console.log('PASS host overrides, non-Nix Git, and invalid profile rejection');

  const initTemplate = fs.readFileSync(path.join(root, 'home/.chezmoi.toml.tmpl'), 'utf8');
  const initConfig = successful(render('abzy-m5', 'darwin', { machine: 'abzy-m5' }, ['execute-template', '--init', initTemplate]));
  assert(initConfig.includes(`sourceDir = ${JSON.stringify(root)}`));
  assert(initConfig.includes('machine = "abzy-m5"'));
  console.log('PASS initialization retains checkout path and machine selection');

  // Parse PowerShell without loading a profile, running tools, or installing anything.
  if (spawnSync('pwsh', ['--version'], { encoding: 'utf8' }).status === 0) {
    const ps = '$tokens = $null; $errors = $null; [System.Management.Automation.Language.Parser]::ParseFile($args[0], [ref]$tokens, [ref]$errors) > $null; if ($errors.Count) { $errors | Out-String | Write-Error; exit 1 }';
    const parser = path.join(temp, 'parse.ps1');
    fs.writeFileSync(parser, ps);
    successful(run('pwsh', ['-NoProfile', '-NonInteractive', '-File', parser, path.join(temp, 'profile.ps1')]));
    console.log('PASS PowerShell syntax');
  } else {
    console.log('SKIP PowerShell syntax: pwsh is unavailable');
  }
  if (spawnSync('nvim', ['--version'], { encoding: 'utf8' }).status === 0) {
    const lua = `local ok, err = pcall(function() for _, file in ipairs(vim.fn.globpath(${JSON.stringify(path.join(root, 'home/dot_config/nvim'))}, '**/*.lua', false, true)) do local chunk, failure = loadfile(file); assert(chunk, failure) end end); if not ok then print(err); vim.cmd('cquit 1') end`;
    successful(run('nvim', ['--headless', '-u', 'NONE', '-i', 'NONE', '-n', '-c', `lua ${lua}`, '-c', 'qa!']));
    console.log('PASS Neovim Lua syntax (no plugins loaded)');
  } else {
    console.log('SKIP Neovim Lua syntax: nvim is unavailable');
  }
  assert.deepEqual(fs.readdirSync(destination), [], 'checks must not apply to the destination');
} finally {
  fs.rmSync(temp, { recursive: true, force: true });
}
