eval "$(/opt/homebrew/bin/brew shellenv)"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# pyenv-virtualenv
eval "$(pyenv virtualenv-init -)"

# fastfetch
fastfetch

# fortune
fortune

echo ""


# Added by OrbStack: command-line tools and integration
# Comment this line if you don't want it to be added again.
# source ~/.orbstack/shell/init.zsh 2>/dev/null || :
