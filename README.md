# abzy's dotfiles

Cross-platform user configuration managed by [chezmoi](https://www.chezmoi.io).
Packages, services, and Zsh belong to the separate
[nix-abzy](https://github.com/abzy128/nix-abzy) repository. These repositories
are independent: dotfile changes do not change the flake revision.

## Hosts and ownership

| Host | OS | Type | Git owner | Desktop |
| --- | --- | --- | --- | --- |
| `bts-n0298` | Linux | workstation | Home Manager | Wayland |
| `abzy-linux` | Linux | workstation | Home Manager | Wayland |
| `abzy-pn41` | Linux | server | chezmoi | none |
| `abzy-m5` | macOS | workstation | Home Manager | macOS |
| `abzy-rog` | Windows | workstation | chezmoi | Windows |

The PN41 has NixOS but currently no Home Manager integration; its Git
configuration is therefore managed here. Zsh is never deployed by chezmoi.
Neovim configuration is shared across all five hosts. Desktop-only files
and Linux hardware helpers are excluded from servers and other OSs.

## Checkout and apply

On an already configured machine, inspect `chezmoi source-path`. The checkout
on the Mac is `~/dev/personal/dotfiles`. Keep using that checkout.

On a new machine, after installing Git and chezmoi separately:

```sh
chezmoi init --source "$HOME/dev/personal/dotfiles" https://github.com/abzy128/dotfiles.git
chezmoi diff
chezmoi apply
```

The same commands work in PowerShell. The init template stores the checkout
location in the local chezmoi configuration. `.chezmoiroot` selects `home/`
inside it.

For the already moved Mac checkout, no reinitialization is required to use
the new layout. Review the diff before applying. Fetch changes separately
with `chezmoi git pull`; `chezmoi update` both fetches and applies.

Host selection defaults to the lowercased hostname. Unknown hosts and OS
mismatches fail before application. If the actual hostname differs, select
an existing host in `chezmoi edit-config`:

```toml
[data]
machine = "abzy-rog"
```

This selects a profile, not an OS emulation: `abzy-rog` must run native Windows
chezmoi. A WSL environment needs its own Linux host entry.

## Declarative configuration

- `home/.chezmoidata/machines.toml`: host types, host inventory, Git ownership,
  and feature overrides. A host's feature values override its type defaults.
- `home/.chezmoidata/features.toml`: each feature's supported OSs and
  destination paths. `home/.chezmoiignore` filters disabled features.
- `home/.chezmoidata/git.toml`: Git identity and signing preferences for
  chezmoi-owned Git. Keep shared preferences consistent with Nix's `git.nix`
  when intentionally changing both; neither repo imports the other.
- `home/.chezmoitemplates/machine.json`: validates and resolves the selected
  host. `chezmoi execute-template '{{ includeTemplate "machine.json" . }}'`
  shows the effective profile.
- `home/`: the destination-shaped deployment tree. Its ignore patterns use
  target names such as `.config/hypr`, not `dot_config/hypr`.
- `home/dot_config/nvim/`: the canonical Neovim content, stored as plain files
  so `chezmoi re-add` works on Linux/macOS. `home/AppData/Local/nvim/` holds
  generated include templates that deploy the same files on Windows.
- `archive/zsh/`: old chezmoi shell files retained for reference, never applied.

To add a non-Nix Linux server, for example:

```toml
[hosts.new-server]
type = "server"
os = "linux"
nix = false
gitOwner = "chezmoi"

[hosts.new-server.features]
nvim = true
zellij = false
```

To add a feature, declare its supported OSs and destination paths, then enable
it in a host type or host override. Hardware/GRUB scripts are disabled for
every current host; the legacy helper feature is rejected on Nix hosts.
Disabling a feature stops managing its files; it does not delete existing
files. No removal scripts run automatically.

## Windows: abzy-rog

The Windows profile deploys Git, Neovim, and native PowerShell profiles for
PowerShell 7 and Windows PowerShell. It does not deploy Unix desktop files,
require symlink privileges, or install packages. Optional PowerShell tools
are initialized only when available.

Default Windows paths are assumed: `%USERPROFILE%/AppData/Local/nvim` and
the profile directories under `%USERPROFILE%/Documents`. If Documents is
redirected (for example by OneDrive), check `$PROFILE` and adapt the target
mapping before applying; this configuration does not relocate Documents.

Git preserves signed commits and the personal/work key fingerprints from the
Nix configuration. Provision Git/GPG and the signing keys separately. It
does not force optional Nix-installed diff or LFS helpers onto Windows.
Existing Neovim plugin/bootstrap behavior is retained; plugin/tool availability
is separate from rendering and deploying these files.

`../dotfiles-win` is an unmaintained reference checkout. Its old hardcoded
user paths, Chocolatey setup, and Vim configuration are not applied. Windows
package management is deliberately outside this repository: no WinGet
installation automation.

## Editing and validation

Edit Neovim content in `home/dot_config/nvim` (or edit `~/.config/nvim` and
`chezmoi re-add`), never the generated templates in `home/AppData/Local/nvim`.
After adding or deleting files, run `node scripts/sync-nvim.mjs` to regenerate
the Windows templates. On Windows, copy changes such as an updated
`lazy-lock.json` back into `home/dot_config/nvim` by hand.

Run from this repository with Node 22+ and chezmoi installed:

```sh
node scripts/check.mjs
git diff --check
```

The checks render every host, verify ownership and OS exclusions, compare
both Neovim deployments with the shared source, test invalid profiles and
overrides, and dry-run application against an empty temporary destination.
PowerShell syntax is checked when `pwsh` is available, and Neovim Lua syntax
when `nvim` is available (without loading plugins). These are rendering
checks, not native Windows application or Neovim plugin integration tests.

The existing cleaned-up Zsh configuration in `nix-abzy` is retained as-is.
The archived shell files are not migrated into it, and chezmoi does not
remove or replace existing shell files.

Original configuration authors and upstream attribution are retained in the
individual files.
