# A thin wrapper around your existing "gt" command to add
# `gt worktree` (or `gt wt`) subcommands via fzf.

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
    # subcommand: ls, add, rm, cd
    cmd2=${1:-}; shift

    case "$cmd2" in
      ls)
        git worktree list
        ;;

      add)
        # create a new worktree and cd into it
        if [[ $# -lt 1 ]]; then
          echo "Usage: gt wt add <path> [<commit-ish>]" >&2
          return 1
        fi
        local dest=$1; shift
        local ref=${1:-HEAD}
        git worktree add "$dest" "$ref" || return
        cd "$dest"
        ;;

      rm)
        sel=$(
          git worktree list \
          | fzf --prompt="gt rm> " \
          | awk '{print $1}'
        )
        if [[ -z "$sel" ]]; then
          echo "gt wt rm: aborted" >&2
          return 1
        fi
        git worktree remove "$sel"
        ;;

      cd)
        sel=$(
          git worktree list \
          | fzf --prompt="gt cd> " \
          | awk '{print $1}'
        )
        if [[ -z "$sel" ]]; then
          echo "gt wt cd: aborted" >&2
          return 1
        fi
        cd "$sel"
        ;;

      *)
        echo "Usage: gt {worktree|wt} {ls|add|rm|cd}" >&2
        return 1
        ;;
    esac

  else
    # not a worktree sub-command → hand off to the real gt
    command gt "$cmd1" "$@"
  fi
}