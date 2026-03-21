# dotfiles

My developer config files, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's included

| Package | Contents |
|---------|----------|
| `zsh` | `.zshrc`, `.zprofile`, `.zshenv` |
| `bash` | `.bashrc` |
| `git` | `.gitconfig`, `.gitignore_global` |
| `tmux` | `.tmux.conf` |
| `nvim` | LazyVim config |
| `atuin` | Shell history config |
| `karabiner` | Keyboard remapping |
| `zed` | Zed editor settings |
| `btop` | System monitor config |

## Install

```bash
git clone https://github.com/fenilsonani/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

This backs up any existing files and creates symlinks via `stow`.

## Add a single package

```bash
cd ~/dotfiles
stow nvim  # only symlink nvim config
```

## Uninstall a package

```bash
cd ~/dotfiles
stow -D nvim  # remove nvim symlinks
```
