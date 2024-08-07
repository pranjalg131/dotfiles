# Homebrew Config
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_CASK_OPTS="--appdir=~/Applications"

# VSCode
export PATH="/Users/pranjalgupta/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
