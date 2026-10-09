# Homebrew uses different prefixes on macOS and Linux.
for brew_binary in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
  if [[ -x "$brew_binary" ]]; then
    eval "$("$brew_binary" shellenv)"
    break
  fi
done
unset brew_binary

# OrbStack installs this separately; keep the integration when it is available.
if [[ -r "$HOME/.orbstack/shell/init.zsh" ]]; then
  source "$HOME/.orbstack/shell/init.zsh"
fi
