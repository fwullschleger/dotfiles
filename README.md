# Dotfiles symlinked on my machine

### Install with stow:
```shell
stow . --no-folding
```
`--no-folding` only links the ‘leaves’ without linking whole directories (which stow calls folding to make fewer symlinks)
