export PATH=/opt/homebrew/bin:$PATH
export DOTNET_ROOT=$HOME/.dotnet'
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools'
if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi
