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
export PATH=$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH
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
# Rust
export PATH="$HOME/.cargo/bin:$PATH"

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

# fd
alias fd='fd --hidden --no-ignore'

# claude
alias cc='CLAUDE_CODE_NO_FLICKER=1 claude'
alias ccm='claude-toggle-1m'

# gh (muscle memory from graphite; gh stack shortcuts live in ~/.config/gh/config.yml)
alias gt='gh'

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

# gt is an alias for gh - complete it the same way
compdef gt=gh

###############################################################################
#  Starship Prompt
###############################################################################
eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

###############################################################################
#  FZF
###############################################################################
export FZF_DEFAULT_COMMAND='fd --type f --follow'
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

bank2ynab() {
  SCRIPT_PATH="$HOME/workspaces/bank2ynab/bank2ynab.sh"

  if [ ! -x "$SCRIPT_PATH" ]; then
    echo "Error: Script not found or not executable: $SCRIPT_PATH"
    return 1
  fi

  "$SCRIPT_PATH" "$@"
}

mdr() {
  local config="$HOME/.config/vantage/config.toml"
  [[ -f "$config" ]] || { echo "No config found at $config"; return 1; }
  
  local selected
  selected=$(python3 -c "
  import tomllib
  with open('$config', 'rb') as f:
    data = tomllib.load(f)
  for r in data.get('repos', []):
    print(f\"{r['name']}\t{r['path']}\")
  " | fzf --multi --with-nth=1,2 --delimiter='\t' --header='Select repos to remove (TAB to multi-select)' | cut -f1)
  
  [[ -z "$selected" ]] && { echo "Nothing selected."; return 0; }
  
  echo "$selected" | while read -r name; do
    md remove -n "$name"
  done
}

claude-toggle-1m() {
  local file="$HOME/workspaces/sanetics-workspace/.claude/settings.json"
  local current
  current=$(jq -r '.env.CLAUDE_CODE_DISABLE_1M_CONTEXT // "0"' "$file")
  local new_val="1"
  [[ "$current" == "1" ]] && new_val="0"
  local tmp=$(mktemp)
  jq --arg v "$new_val" '.env.CLAUDE_CODE_DISABLE_1M_CONTEXT = $v' "$file" > "$tmp" && mv "$tmp" "$file"
  if [[ "$new_val" == "1" ]]; then
    echo "1M context: DISABLED"
  else
    echo "1M context: ENABLED"
  fi
}

###############################################################################
#  Evals
###############################################################################
eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"

###############################################################################
# Autoloads
###############################################################################
autoload -U zmv

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
