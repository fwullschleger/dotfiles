#!/usr/bin/env bash
# --no-folding only links the ‘leaves’ without linking whole directories (which stow calls folding to make fewer symlinks)
stow . --no-folding
