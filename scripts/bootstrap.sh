#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
INSTALL_PACKAGES=false
DRY_RUN=false
CHECK_ONLY=false

usage() {
	cat <<'EOF'
Usage: bootstrap.sh [--packages] [--dry-run] [--check]

  --packages  Install Homebrew packages and the current Node LTS.
  --dry-run   Print the changes without modifying the machine.
  --check     Verify links, required tools, and MonoLisa without modifying anything.
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--packages) INSTALL_PACKAGES=true ;;
	--dry-run) DRY_RUN=true ;;
	--check) CHECK_ONLY=true ;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		usage >&2
		exit 2
		;;
	esac
	shift
done

if $CHECK_ONLY && $DRY_RUN; then
	echo "--check and --dry-run cannot be used together" >&2
	exit 2
fi

link_specs=(
	"$DOTFILES_DIR/.zshrc|$HOME/.zshrc"
	"$DOTFILES_DIR/tmux/.tmux.conf|$HOME/.tmux.conf"
	"$DOTFILES_DIR/wezterm|$HOME/.config/wezterm"
	"$DOTFILES_DIR/aerospace|$HOME/.config/aerospace"
	"$DOTFILES_DIR/starship|$HOME/.config/starship"
	"$DOTFILES_DIR/nvim|$HOME/.config/nvim"
	"$DOTFILES_DIR/bin/tmux-sessionizer|$HOME/.local/bin/tmux-sessionizer"
)

same_file() {
	local source="$1"
	local target="$2"
	[[ -e "$target" ]] && [[ "$source" -ef "$target" ]]
}

link_dotfile() {
	local source="$1"
	local target="$2"

	if same_file "$source" "$target"; then
		printf "already linked  %s\n" "$target"
		return
	fi

	if $DRY_RUN; then
		if [[ -e "$target" || -L "$target" ]]; then
			printf "would back up  %s\n" "$target"
		fi
		printf "would link     %s -> %s\n" "$target" "$source"
		return
	fi

	mkdir -p "$(dirname "$target")"
	if [[ -e "$target" || -L "$target" ]]; then
		local relative_target="${target#"$HOME"/}"
		mkdir -p "$BACKUP_DIR/$(dirname "$relative_target")"
		mv "$target" "$BACKUP_DIR/$relative_target"
		printf "backed up      %s\n" "$target"
	fi

	ln -s "$source" "$target"
	printf "linked         %s\n" "$target"
}

has_monolisa() {
	find "$HOME/Library/Fonts" -maxdepth 1 -type f \
		\( -iname 'MonoLisa-Regular.ttf' -o -iname 'MonoLisa-Regular.otf' \) \
		-print -quit 2>/dev/null | grep -q .
}

check_setup() {
	local failed=0
	local spec source target command

	for spec in "${link_specs[@]}"; do
		IFS='|' read -r source target <<<"$spec"
		if same_file "$source" "$target"; then
			printf "%-18s %s\n" "link OK" "$target"
		else
			printf "%-18s %s\n" "link MISSING" "$target"
			failed=1
		fi
	done

	for command in git nvim tmux wezterm starship fnm node pnpm uv ruff ty tree-sitter; do
		if command -v "$command" >/dev/null 2>&1; then
			printf "%-18s %s\n" "tool OK" "$command"
		else
			printf "%-18s %s\n" "tool MISSING" "$command"
			failed=1
		fi
	done

	if has_monolisa; then
		printf "%-18s %s\n" "font OK" "MonoLisa Regular"
	else
		printf "%-18s %s\n" "font MISSING" "MonoLisa Regular (Meslo fallback will be used)"
		failed=1
	fi

	return "$failed"
}

if $CHECK_ONLY; then
	check_setup
	exit $?
fi

if $INSTALL_PACKAGES; then
	if ! command -v brew >/dev/null 2>&1; then
		echo "Homebrew is required for --packages: https://brew.sh" >&2
		exit 1
	fi

	if $DRY_RUN; then
		echo "would install  Homebrew bundle and current Node LTS"
	else
		brew tap nikitabobko/tap
		brew trust --cask nikitabobko/tap/aerospace
		brew bundle --file "$DOTFILES_DIR/Brewfile"

		eval "$(fnm env --shell bash)"
		fnm install --lts --use
		fnm default "$(fnm current)"
	fi
fi

for spec in "${link_specs[@]}"; do
	IFS='|' read -r source target <<<"$spec"
	link_dotfile "$source" "$target"
done

if ! has_monolisa; then
	echo "warning: install your licensed MonoLisa-Regular font in ~/Library/Fonts" >&2
fi

if $DRY_RUN; then
	echo "would install  TPM and configured tmux plugins"
	echo "would sync     Neovim plugins, Tree-sitter parsers, and Mason servers"
	exit 0
fi

if [[ ! -d "$HOME/.tmux/plugins/tpm/.git" ]]; then
	git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
"$HOME/.tmux/plugins/tpm/bin/install_plugins"

if command -v nvim >/dev/null 2>&1; then
	nvim --headless "+Lazy! sync" +qa

	nvim --headless \
		"+lua local ok = require('nvim-treesitter').install({ 'bash', 'c', 'clojure', 'css', 'go', 'html', 'javascript', 'json', 'lua', 'markdown', 'markdown_inline', 'python', 'query', 'rust', 'tsx', 'typescript', 'vim', 'vimdoc' }):wait(300000); if not ok then error('Tree-sitter parser installation failed') end" \
		+qa

	nvim --headless \
		-c "MasonInstall vtsls eslint-lsp gopls lua-language-server rust-analyzer tailwindcss-language-server ruff ty clangd html-lsp terraform-ls prisma-language-server json-lsp yaml-language-server" \
		-c qall
fi

echo "Bootstrap complete. Reload with: exec zsh -l"
if [[ -d "$BACKUP_DIR" ]]; then
	echo "Replaced files were saved in: $BACKUP_DIR"
fi
