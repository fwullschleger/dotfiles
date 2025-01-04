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

###############################################################################
#  Completions
###############################################################################
# Reevaluate the prompt string each time it's displaying a prompt
setopt prompt_subst
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
#  Aliases & Functions
###############################################################################
# Eza
export EZA_CONFIG_DIR=~/.config/eza
alias l="eza -l --git -a"
alias ll="eza -a"
alias lt="eza --tree --level=2 --long --git"
alias ltree="eza --tree --level=2 --git"

# FZF
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Navigation
# Change directory and list contents
cl() { cd "$@" && l; }
# Fuzzy find a directory, change to it, and list contents
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
# Fuzzy find a file and copy its path to clipboard
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy }
# Fuzzy find a file and open it in vim
fv() { vim "$(find . -type f -not -path '*/.*' | fzf)" }