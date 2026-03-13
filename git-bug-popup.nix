{
  lib,
  pkgs,
  ...
}: let
  deps = with pkgs; [git-crypt git-bug];
in
  pkgs.writeShellScriptBin "git-bug-popup.sh"
  /*
  sh
  */
  ''
    export PATH=${lib.makeBinPath deps}:$PATH

    detect_git_root() {
      local dir="$PWD"
      while [ "$dir" != "/" ]; do
        if [ -d "$dir/.git" ]; then
          echo "$dir"
          return 0
        fi
        dir="$(dirname "$dir")"
      done
      echo ""
    }

    sanitize() {
      echo "$1" | sed 's/[^A-Za-z0-9]/_/g'
    }

    repo_root="$(detect_git_root)"
    [ -z "$repo_root" ] && exit 0

    session="_gitbug_$(tmux display -p '#S')_$(sanitize "$repo_root")"

    if ! tmux has -t "$session" 2>/dev/null; then
      session_id="$(
        tmux new-session -dP -s "$session" -F '#{session_id}' -c "$repo_root" "git bug termui"
      )"
      tmux set-option -s -t "$session_id" key-table popup
      tmux set-option -s -t "$session_id" status off
      tmux set-option -s -t "$session_id" prefix None
      session="$session_id"
    fi

    exec tmux attach -t "$session" >/dev/null
  ''
