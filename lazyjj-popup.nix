{
  lib,
  pkgs,
  ...
}: let
  deps = with pkgs; [git-crypt];
in
  pkgs.writeShellScriptBin "vcs-popup.sh"
  /*
  sh
  */
  ''
    export PATH=${lib.makeBinPath deps}:$PATH
    session="_lazyjj_$(tmux display -p '#S')"

    detect_repo_type() {
      local dir="$PWD"
      while [ "$dir" != "/" ]; do
        [ -d "$dir/.jj" ]  && { echo "jujutsu"; return 0; }
        [ -d "$dir/.git" ] && { echo "git";     return 0; }
        dir="$(dirname "$dir")"
      done
      echo "none"
    }

    case "$(detect_repo_type)" in
      jujutsu) target=${lib.getExe pkgs.jjui} ;;
      git)     target=${lib.getExe pkgs.lazygit} ;;
      *)       exit 0 ;;
    esac

    if ! tmux has -t "$session" 2>/dev/null; then
      session_id="$(tmux new-session -dP -s "$session" -F '#{session_id}' "$target")"
      tmux set-option -s -t "$session_id" key-table popup
      tmux set-option -s -t "$session_id" status off
      tmux set-option -s -t "$session_id" prefix None
      session="$session_id"
    fi

    exec tmux attach -t "$session" >/dev/null
  ''
