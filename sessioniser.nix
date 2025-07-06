{
  lib,
  pkgs,
  fzf ? pkgs.fzf,
  zoxide ? pkgs.zoxide,
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
        candidates=$(
            {
                for dir in ${directories}; do
                    ${getExe zoxide} query -ls "$dir" 2>/dev/null
                done \
                | awk '{score=$1; $1=""; sub(/^ +/,""); printf "%s\t%s\n",score,$0}'
            } \
            | sort -t '	' -k1,1nr -k2,2 -u
        )

        selected=$(printf '%s\n' "$candidates" \
            | ${fzf}/bin/fzf                                 \
                  --tmux center                              \
                  --delimiter='\t'                           \
                  --with-nth=2..                             )
    fi

    [ -z "$selected" ] && exit 0

    selected=''${selected#*	}

    selected_name=$(basename "$selected" | tr . _)
    tmux_running=$(pgrep tmux)
    zoxide add "$selected"

    if [ -z "$TMUX" ] && [ -z "$tmux_running" ]; then
        exec tmux new-session -s "$selected_name" -c "$selected"
    fi

    if ! tmux has-session -t="$selected_name" 2>/dev/null; then
        tmux new-session -ds "$selected_name" -c "$selected"
    fi

    tmux switch-client -t "$selected_name"
  ''
