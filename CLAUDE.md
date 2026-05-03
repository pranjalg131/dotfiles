# dotfiles

GNU Stow-managed dotfiles for macOS. Each top-level directory is a "package" that maps to `$HOME` when stowed.

## Structure

```
dotfiles/
├── ghostty/     # Ghostty terminal config
├── git/         # .gitconfig, .gitignore_global
├── homebrew/    # Brewfile
├── macos/       # macOS defaults scripts
├── mise/        # .mise.toml (global tool versions)
├── starship/    # starship.toml prompt config
├── tmux/        # .tmux.conf
├── vim/         # .vimrc or neovim config
└── zsh/         # .zshrc, .zprofile, aliases
```

## Usage

```bash
# Stow a single package (creates symlinks in $HOME)
stow ghostty

# Stow all packages
stow */

# Unstow (remove symlinks)
stow -D ghostty

# Preview without applying (dry run)
stow -n ghostty
```

## Adding a New Tool Config

1. Create a new top-level directory named after the tool: `mkdir newtool/`
2. Mirror the path relative to `$HOME` inside that directory.
   - Example: `~/.config/newtool/config.toml` → `dotfiles/newtool/.config/newtool/config.toml`
3. Run `stow newtool` from the `dotfiles/` root.
4. Verify the symlink: `ls -la ~/.config/newtool/`

## Conventions

- All tool configs live inside their named package directory — no files at the dotfiles root.
- Use `.stowrc` if it exists to set default target and ignore patterns.
- Secrets (API keys, tokens) must NOT be committed — use environment variable references or secret managers.
- macOS-specific configs go in `macos/` — keep them idempotent (safe to run multiple times).
