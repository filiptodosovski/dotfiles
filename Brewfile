# Shell, navigation, and source control
brew "atuin"
brew "bat"
brew "eza"
brew "fd"
brew "fnm"
brew "fzf"
brew "fzf-tab"
brew "gh"
brew "git"
brew "jq"
brew "lazygit"
brew "pnpm"
brew "ripgrep"
brew "starship"
brew "tmux"
brew "zoxide"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# Editor and language tooling
brew "neovim"
brew "go"
brew "prettier"
brew "prettierd"
brew "ruff"
brew "stylua"
brew "tree-sitter-cli"
brew "ty"
brew "uv"

if OS.mac?
  tap "nikitabobko/tap"
  cask "nikitabobko/tap/aerospace"
  cask "font-meslo-lg-nerd-font"
  cask "wezterm@nightly"
else
  brew "zsh"
  brew "unzip"
  brew "fontconfig"
  brew "wl-clipboard" if ENV["WAYLAND_DISPLAY"]
  brew "xclip" if ENV["DISPLAY"] && !ENV["WAYLAND_DISPLAY"]
end
