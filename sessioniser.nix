{
  lib,
  pkgs,
  # How deep to search the directories
  depth ? 1,
  # Where to search in
  targets ? [],
  ...
}: let
  inherit (pkgs) writeShellScriptBin;
  inherit (lib) getExe;
  inherit (builtins) concatStringsSep;
  directories = concatStringsSep " " targets;
in
  writeShellScriptBin "sessioniser"
  /*
  sh
  */
  ''
    if [ "$#" -eq 1 ]; then
    	selected=$1
    else
    	selected=$(${getExe pkgs.fd} \
    							--type directory \
    							--min-depth 0 \
    							--max-depth ${toString depth} \
    							--exclude Archives \
    							. ${directories} \
    							| ${getExe pkgs.fzf})
    fi

    if [ -z "$selected" ]; then
    	exit 0
    fi

    selected_name=$(basename "$selected" | tr . _)
    tmux_running=$(pgrep tmux)

    if [ -z "$TMUX" ] && [ -z "$tmux_running" ]; then
    	tmux new-session -s "$selected_name" -c "$selected"
    	exit 0
    fi

    if ! tmux has-session -t="$selected_name" 2>/dev/null; then
    	tmux new-session -ds "$selected_name" -c "$selected"
    fi

    tmux switch-client -t "$selected_name"
  ''
