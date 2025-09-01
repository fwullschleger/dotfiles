# A thin wrapper around your existing "gt" command to add
# `gt worktree` (or `gt wt`) subcommands via fzf.

# define the wrapper function
gt() {
  local cmd1 cmd2 sel

  # if no args, just call real gt
  if [[ $# -eq 0 ]]; then
    command gt
    return
  fi

  cmd1=$1; shift

  # intercept "worktree" or "wt"
  if [[ "$cmd1" == "worktree" || "$cmd1" == "wt" ]]; then
    # subcommand: ls, rm, cd
    cmd2=${1:-}; shift

    case "$cmd2" in
      ls)
        git worktree list --porcelain \
          | awk '/^worktree /{print $2}'
        ;;

      rm)
        sel=$(
          git worktree list --porcelain \
            | awk '/^worktree /{print $2}' \
            | fzf --prompt="gt rm> "
        )
        if [[ -z "$sel" ]]; then
          echo "gt wt rm: aborted" >&2; return 1
        fi
        git worktree remove "$sel"
        ;;

      cd)
        sel=$(
          git worktree list --porcelain \
            | awk '/^worktree /{print $2}' \
            | fzf --prompt="gt cd> "
        )
        if [[ -z "$sel" ]]; then
          echo "gt wt cd: aborted" >&2; return 1
        fi
        cd "$sel"
        ;;

      *)
        echo "Usage: gt {worktree|wt} {ls|rm|cd}" >&2
        return 1
        ;;
    esac

  else
    # not a worktree sub-command → hand off to the real gt
    command gt "$cmd1" "$@"
  fi
}