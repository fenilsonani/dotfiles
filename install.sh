#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

PACKAGES=(zsh bash git tmux nvim atuin karabiner zed btop claude)

echo "Dotfiles installer"
echo "==================="
echo "Dotfiles dir: $DOTFILES_DIR"
echo ""

# Install stow if missing
if ! command -v stow &>/dev/null; then
    echo "Installing GNU Stow..."
    if command -v brew &>/dev/null; then
        brew install stow
    else
        echo "Error: stow not found and brew not available. Install stow manually."
        exit 1
    fi
fi

# Backup existing files before stowing
backup_if_exists() {
    local file="$1"
    if [ -e "$file" ] && [ ! -L "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        local rel="${file#$HOME/}"
        local backup_path="$BACKUP_DIR/$rel"
        mkdir -p "$(dirname "$backup_path")"
        mv "$file" "$backup_path"
        echo "  Backed up: $file -> $backup_path"
    elif [ -L "$file" ]; then
        rm "$file"
    fi
}

# Backup conflicting files
echo "Checking for existing files..."
for pkg in "${PACKAGES[@]}"; do
    pkg_dir="$DOTFILES_DIR/$pkg"
    while IFS= read -r -d '' file; do
        rel="${file#$pkg_dir/}"
        target="$HOME/$rel"
        backup_if_exists "$target"
    done < <(find "$pkg_dir" -type f -print0)
done

# Stow each package
echo ""
echo "Stowing packages..."
cd "$DOTFILES_DIR"
for pkg in "${PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        stow -v "$pkg"
        echo "  Stowed: $pkg"
    fi
done

echo ""
echo "Done! All dotfiles are symlinked."
if [ -d "$BACKUP_DIR" ]; then
    echo "Backups saved to: $BACKUP_DIR"
fi
