###############################################################################
#  Exports
###############################################################################
# Python
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
# Homebrew
export PATH=/opt/homebrew/bin:$PATH
# HOME bin
export PATH="$HOME/.bin:$PATH"
# Config Home
export XDG_CONFIG_HOME="$HOME/.config"
# .Net
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
# EDITOR
export EDITOR=/opt/homebrew/bin/vim
# Gemini-CLI
#export GOOGLE_CLOUD_PROJECT="keen-precinct-464918-p7"
# Homebrew OpenJDK/Java
export PATH="$(brew --prefix openjdk)/bin:$PATH"
export JAVA_HOME="$(brew --prefix openjdk)/libexec/openjdk.jdk/Contents/Home"
# Gradle
export PATH="/opt/homebrew/opt/gradle@8/bin:$PATH"
# Ripgrep
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
# JetBrains Toolbox Scripts
export PATH="$HOME/Library/Application Support/JetBrains/Toolbox/scripts:$PATH"

###############################################################################
#  Aliases & Key Bindings
###############################################################################
bindkey '^l' vi-forward-word
bindkey '^h' vi-backward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search

# VI Mode!!!
bindkey jj vi-cmd-mode

# Zoxide
alias j='z'

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
#  Auto-Suggestions
###############################################################################
#source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
#bindkey '  ' autosuggest-accept
#bindkey '^ ' autosuggest-execute
#bindkey '^u' autosuggest-toggle

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

#compdef gt
###-begin-gt-completions-###
#
# yargs command completion script
#
# Installation: gt completion >> ~/.zshrc
#    or gt completion >> ~/.zprofile on OSX.
#
_gt_yargs_completions()
{
  local cmd1="${words[2]}"
  local cmd2="${words[3]}"

  if [[ "$cmd1" == "wt" || "$cmd1" == "worktree" ]] && [[ "$cmd2" == "add" ]]; then
    # Parse words after "add" (index 4 onward, up to but not including current)
    local skip_next=0 positional=0
    for (( i=4; i<CURRENT; i++ )); do
      if (( skip_next )); then skip_next=0; continue; fi
      if [[ "${words[$i]}" == "-b" ]]; then skip_next=1; else (( positional++ )); fi
    done

    # What is the current word?
    if [[ "${words[CURRENT-1]}" == "-b" ]]; then
      # completing the branch name that follows -b
      local -a branches
      branches=( ${(f)"$(git branch --format='%(refname:short)' 2>/dev/null)"} )
      _describe 'branch' branches
    elif (( positional == 0 )); then
      # first positional: destination path
      _files -/
    elif (( positional == 1 )); then
      # second positional: existing branch to check out
      local -a branches
      branches=( ${(f)"$(git branch --format='%(refname:short)' 2>/dev/null)"} )
      _describe 'branch' branches
    else
      # offer -b flag if not yet used
      local -a opts; opts=('-b')
      _describe 'option' opts
    fi
    return
  fi

  # Default: delegate to graphite yargs completions
  local reply
  local si=$IFS
  IFS=$'\n' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" gt --get-yargs-completions "${words[@]}"))
  IFS=$si
  _describe 'values' reply
}
compdef _gt_yargs_completions gt
###-end-gt-completions-###

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

source ~/.gt-wrapper-function.sh

###############################################################################
#  Evals
###############################################################################
eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"

###############################################################################
# Autoloads
###############################################################################
autoload -U zmv
