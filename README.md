# Dotfiles symlinked on my machine

You may also be interested in my 
- [Mac Ansible Playbook](https://github.com/fwullschleger/mac-playbook), which configures a Mac from scratch using Ansible.
- [Karabiner Hyper Key Configuration](https://github.com/fwullschleger/karabiner-hyperkey), which configures Caps Lock as Hyper Key with multiple keyboard sub-layers for maximum flexibility.

### Install with stow:
```shell
stow . --no-folding
```
`--no-folding` only links the ‘leaves’ without linking whole directories (which stow calls folding to make fewer symlinks)