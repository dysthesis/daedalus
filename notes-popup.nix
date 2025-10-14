{
  lib,
  pkgs,
  ...
}: let
  deps = with pkgs; [git-crypt];
in
  pkgs.writeShellScriptBin "notes-popup.sh"
  /*
  sh
  */
  ''
    export PATH=${lib.makeBinPath deps}:$PATH
    session="_notes_$(tmux display -p '#S')"

    if ! tmux has -t "$session" 2>/dev/null; then
      session_id="$(tmux new-session -dP -s "$session" -F '#{session_id}' nvim NOTES.md)"
      tmux set-option -s -t "$session_id" key-table popup
      tmux set-option -s -t "$session_id" status off
      tmux set-option -s -t "$session_id" prefix None
      session="$session_id"
    fi

    exec tmux attach -t "$session" >/dev/null
  ''
