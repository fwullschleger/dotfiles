# Simpler gt worktree wrapper:
# - add: supports optional "-b <branch>"
# - rm/remove: supports optional "-f/--force" (and "--no-force")
# - ls, cd helpers remain
# - other subcommands fall through to `git worktree`

gt() {
  local cmd1 cmd2

  if [[ $# -eq 0 ]]; then
    command gt
    return
  fi

  cmd1=$1
  shift

  if [[ "$cmd1" == "worktree" || "$cmd1" == "wt" ]]; then
    cmd2=${1:-}
    [[ -n "$cmd2" ]] && shift

    case "$cmd2" in
      ls | list)
        git worktree list "$@"
        ;;

      add)
        local branch_arg=()
        if [[ "${1:-}" == "-b" ]]; then
          if [[ -z "${2:-}" ]]; then
            echo "gt wt add: -b requires <branch>" >&2
            return 1
          fi
          branch_arg=(-b "$2")
          shift 2
        fi

        if [[ $# -lt 1 ]]; then
          echo "Usage: gt wt add -b <new-branch> <path> <existing-branch>" >&2
          return 1
        fi

        local dest=$1
        shift

        if [[ $# -gt 0 ]]; then
          git worktree add "${branch_arg[@]}" "$dest" "$1" || return
        else
          git worktree add "${branch_arg[@]}" "$dest" || return
        fi

        cd "$dest"
        ;;

      rm | remove)
        # Usage: gt wt rm [-f|--force|--no-force] [<worktree>]
        local force_flag=()
        case "${1:-}" in
          -f | --force)
            force_flag=(--force)
            shift
            ;;
          --no-force)
            force_flag=(--no-force)
            shift
            ;;
        esac

        if [[ $# -gt 0 ]]; then
          # Path provided -> pass through
          git worktree remove "${force_flag[@]}" "$@"
        else
          # No path -> interactive picker (robust parsing)
          local sel
          sel=$(
            git worktree list --porcelain |
              awk '/^worktree /{ sub(/^worktree /,""); print }' |
              fzf --prompt="gt wt rm> " --height=30% --border --reverse
          )
          if [[ -z "$sel" ]]; then
            echo "gt wt rm: aborted" >&2
            return 1
          fi
          git worktree remove "${force_flag[@]}" "$sel"
        fi
        ;;

      cd)
        # Interactive cd to a worktree (robust parsing)
        local sel
        sel=$(
          git worktree list --porcelain |
            awk '/^worktree /{ sub(/^worktree /,""); print }' |
            fzf --prompt="gt wt cd> " --height=30% --border --reverse
        )
        if [[ -z "$sel" ]]; then
          echo "gt wt cd: aborted" >&2
          return 1
        fi
        cd "$sel"
        ;;

      "" )
        git worktree
        ;;

      *)
        # Fall through for any other subcommand
        git worktree "$cmd2" "$@"
        ;;
    esac
  elif [[ "$cmd1" == "submit" ]]; then
    command gt submit --confirm "$@"
  else
    command gt "$cmd1" "$@"
  fi
}