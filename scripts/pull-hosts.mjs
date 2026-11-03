#!/usr/bin/env node
// Fast-forward the dotfiles checkout on every reachable host after a push.
//
// Usage: node scripts/pull-hosts.mjs [host...]
//
// Hosts default to those in home/.chezmoidata/machines.toml, minus this
// machine and retired hosts. Each is reached as abzy@<tailscale IP>, falling
// back to the plain hostname. Only pulls the source checkout, at
// ~/dev/personal/dotfiles or chezmoi's default ~/.local/share/chezmoi; never
// runs `chezmoi apply`. Skips hosts that are unreachable or whose checkout is
// missing, has uncommitted changes to tracked files, or is not on main.
//
// Every remote command is a single `git -C <checkout> ...` with no shell
// syntax, so it runs the same under sh, cmd and PowerShell (SSH sessions start
// in the home directory on Linux, macOS and Windows).
import { execFileSync, spawnSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const checkouts = ['dev/personal/dotfiles', '.local/share/chezmoi'];
const retired = new Set(['abzy-linux']);
const self = os.hostname().split('.')[0].toLowerCase();

function configuredHosts() {
  const toml = fs.readFileSync(path.join(root, 'home/.chezmoidata/machines.toml'), 'utf8');
  return [...toml.matchAll(/^\[hosts\.([^.\]]+)\]$/gm)].map((m) => m[1]);
}

function address(host) {
  try {
    const ip = execFileSync('tailscale', ['ip', '-4', host], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] })
      .split('\n')[0].trim();
    if (ip) return ip;
  } catch {}
  return host;
}

function remote(addr, checkout, ...args) {
  const r = spawnSync('ssh', ['-o', 'ConnectTimeout=5', '-o', 'BatchMode=yes', `abzy@${addr}`, 'git', '-C', checkout, ...args],
    { encoding: 'utf8' });
  return { code: r.status, out: `${r.stdout}${r.stderr}`.trim() };
}

function pull(host) {
  const addr = address(host);
  let checkout, branch;
  for (checkout of checkouts) {
    branch = remote(addr, checkout, 'rev-parse', '--abbrev-ref', 'HEAD');
    if (branch.code === 255) return 'unreachable';
    if (branch.code === 0) break;
  }
  if (branch.code !== 0) return 'skip: no checkout';
  if (branch.out !== 'main') return `skip: ${checkout} on branch ${branch.out}`;
  const status = remote(addr, checkout, 'status', '--porcelain', '--untracked-files=no');
  if (status.code !== 0) return `failed: ${status.out}`;
  if (status.out) return `skip: ${checkout} has uncommitted changes`;
  const before = remote(addr, checkout, 'rev-parse', '--short', 'HEAD').out;
  const result = remote(addr, checkout, 'pull', '-q', '--ff-only');
  if (result.code !== 0) return `failed: ${result.out}`;
  const after = remote(addr, checkout, 'rev-parse', '--short', 'HEAD').out;
  return `${checkout}: ` + (before === after ? `up to date at ${after}` : `${before} -> ${after}`);
}

const hosts = process.argv.length > 2
  ? process.argv.slice(2)
  : configuredHosts().filter((h) => h !== self && !retired.has(h));

let failed = false;
for (const host of hosts) {
  const line = pull(host);
  if (line.startsWith('failed')) failed = true;
  console.log(`${host}: ${line}`);
}
process.exit(failed ? 1 : 0);
