# Dotfiles repository

- This is the active chezmoi repository, separate from `../nix-abzy`.
- `.chezmoiroot` selects `home/`. Only files under that source-state tree deploy.
- Define machines and host types in `home/.chezmoidata/machines.toml`; define feature destinations and supported OSs in `features.toml` alongside it. Reject unknown machines and incompatible OS selections.
- Zsh is owned by Home Manager in `../nix-abzy`. `archive/zsh/` is reference material and must not deploy.
- Git stays in Home Manager where a host declares `gitOwner = "home-manager"`. Chezmoi manages Git only on hosts declaring `gitOwner = "chezmoi"`; do not generate competing Git configuration files.
- Neovim files live as plain files in `home/dot_config/nvim/` so `chezmoi re-add` works; do not make them templates. `home/AppData/Local/nvim/` is generated: after adding or removing Neovim files, run `node scripts/sync-nvim.mjs`. Do not duplicate configuration content in those templates.
- `abzy-rog` is native Windows. Deploy Neovim under `AppData/Local/nvim`, and PowerShell profiles under `Documents/PowerShell` and `Documents/WindowsPowerShell`. Do not require Windows symlinks.
- `../dotfiles-win` is an unmaintained reference only. Do not apply it or copy its hardcoded usernames and package-manager integration.
- No package installers, WinGet automation, or automatic fetching/application during Nix activation.
- Keep credentials out of source. Git signing keys in template data are public fingerprints; provisioning private keys is separate.
- Check `git status --short` before and after changes. Run `node scripts/check.mjs` (Node 22+ and chezmoi); it renders all hosts and dry-runs only against a temporary destination. PowerShell parsing is included when `pwsh` is available.
- Do not apply to the user's real home or switch Nix configurations unless explicitly requested.
