###############################################################################
#  Exports
###############################################################################
# Python
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
# Homebrew
export PATH=/opt/homebrew/bin:$PATH
# HOME bin
export PATH="$HOME/bin:$PATH"
# .Net
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
# EDITOR
export EDITOR=/opt/homebrew/bin/vim
# Gemini-CLI
export GOOGLE_CLOUD_PROJECT="keen-precinct-464918-p7"

###############################################################################
#  Completions
###############################################################################
# Reevaluate the prompt string each time it's displaying a prompt
setopt prompt_subst

# Add Homebrew's Zsh Completions to FPATH
fpath=($(brew --prefix)/share/zsh/site-functions $fpath)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload bashcompinit && bashcompinit
autoload -Uz compinit
compinit

###############################################################################
#  Auto-Suggestions
###############################################################################
#source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
#bindkey '  ' autosuggest-accept
#bindkey '^ ' autosuggest-execute

bindkey '^u' autosuggest-toggle
bindkey '^l' vi-forward-word
bindkey '^h' vi-backward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search

# VI Mode!!!
bindkey jj vi-cmd-mode

###############################################################################
#  Starship Prompt
###############################################################################
eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

###############################################################################
#  FZF
###############################################################################
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

###############################################################################
#  Aliases
###############################################################################
# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# Eza
export EZA_CONFIG_DIR=~/.config/eza
alias l="eza -l --git -a"
alias ll="eza -a"
alias lt="eza --tree --level=2 --long --git"
alias ltree="eza --tree --level=2 --git"


###############################################################################
#  Functions
###############################################################################
# Navigation
# Change directory and list contents
cl() { cd "$@" && l; }
# Fuzzy find a directory, change to it, and list contents
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
# Fuzzy find a file and copy its path to clipboard
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy }
# Fuzzy find a file and open it in vim
fv() { vim "$(find . -type f -not -path '*/.*' | fzf)" }

# Copy Context to clipboard
cc() {
  VENV_DIR="$HOME/scripts/venv"
  
  if [ ! -d "$VENV_DIR" ]; then
    echo "Virtual environment not found in $VENV_DIR."
    return 1
  fi

  source "$VENV_DIR/bin/activate"
  ~/scripts/copy-files-to-clipboard.sh
  deactivate
}

bank2ynab() {
  SCRIPT_PATH="$HOME/workspaces/bank2ynab/bank2ynab.sh"

  if [ ! -x "$SCRIPT_PATH" ]; then
    echo "Error: Script not found or not executable: $SCRIPT_PATH"
    return 1
  fi

  "$SCRIPT_PATH" "$@"
}

###############################################################################
#  Evals
###############################################################################
eval "$(atuin init zsh)"