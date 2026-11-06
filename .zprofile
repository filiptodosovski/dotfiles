# Homebrew uses different prefixes on macOS and Linux.
for brew_binary in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
  if [[ -x "$brew_binary" ]]; then
    eval "$("$brew_binary" shellenv)"
    break
  fi
done
unset brew_binary

# pnpm keeps global executables in bin; retain the home path for older installs.
if [[ "$OSTYPE" == darwin* ]]; then
  export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
else
  export PNPM_HOME="${PNPM_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/pnpm}"
fi
typeset -U path
path=("$PNPM_HOME/bin" "$PNPM_HOME" $path)
export PATH

# OrbStack installs this separately; keep the integration when it is available.
if [[ -r "$HOME/.orbstack/shell/init.zsh" ]]; then
  source "$HOME/.orbstack/shell/init.zsh"
fi

# Installers that append to ~/.zprofile would edit this repo through the symlink;
# machine-specific login lines go in this untracked file instead.
if [[ -r "$HOME/.zprofile.local" ]]; then source "$HOME/.zprofile.local"; fi
