###############################################################################
#  Exports
###############################################################################
# Python
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
# Homebrew
export PATH=/opt/homebrew/bin:$PATH
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
