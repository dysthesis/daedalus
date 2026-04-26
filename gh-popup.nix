{
  lib,
  gh,
  gh-dash,
  writeShellScriptBin,
  ...
}: let
  deps = [gh gh-dash];
in
  writeShellScriptBin "gh-popup.sh"
  /*
  sh
  */
  ''
    export PATH=${lib.makeBinPath deps}:$PATH
    session="_vcs_$(tmux display -p '#S')"

    detect_repo_type() {
      local dir="$PWD"
      while [ "$dir" != "/" ]; do
        [ -d "$dir/.jj" ]  && { echo "jujutsu"; return 0; }
        [ -d "$dir/.git" ] && { echo "git";     return 0; }
        dir="$(dirname "$dir")"
      done
      echo "none"
    }

    if ! tmux has -t "$session" 2>/dev/null; then
      session_id="$(
        tmux new-session -dP -s "$session" -F '#{session_id}' "${lib.getExe gh} dash"
      )"
      tmux set-option -s -t "$session_id" key-table popup
      tmux set-option -s -t "$session_id" status off
      tmux set-option -s -t "$session_id" prefix None
      session="$session_id"
    fi

    exec tmux attach -t "$session" >/dev/null
  ''
