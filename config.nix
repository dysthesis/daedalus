{
  pkgs,
  lib,
  targets ? [],
  bash ? pkgs.bash,
  shell ? "${lib.getExe bash}",
  fzf,
  jjui,
  lazygit,
  ...
}: let
  inherit (lib.babel.tmux) mkTmuxConfig;
  inherit (builtins) readFile;
  inherit
    (lib)
    getExe
    ;

  extra-config =
    /*
    sh
    */
    ''
      ${readFile ./tmux.conf}
      run-shell "${lib.getExe bash} ${./theme.tmux}"
      bind -n C-f \
        run-shell \
          "tmux neww ${getExe sessioniser}"
      bind -n M-g \
        display-popup \
          -E -w 75% \
          -h 75% \
          -b rounded \
          -T "  | VCS " \
          "${getExe vcs-popup}"
      bind -n M-n \
        display-popup \
          -E -w 75% \
          -h 75% \
          -b rounded \
          -T "  | Notes " \
          "${getExe notes-popup}"
      bind -n M-t \
        display-popup \
          -E \
          -w 75% \
          -h 75% \
          -b rounded \
          -T "  | Terminal " \
          "${getExe popup}"
      bind-key -T copy-mode-vi o \
        send-keys \
          -X copy-pipe \
          'cd #{pane_current_path}; xargs -I {} echo "echo {}" | bash | xargs open' \; \
        if -F "#{alternate_on}" { send-keys -X cancel }
      bind-key -T copy-mode-vi O \
        send-keys \
          -X copy-pipe-and-cancel \
          'tmux send-keys "C-q"; xargs -I {} tmux send-keys "${EDITOR:-vi} {}"; tmux send-keys "C-m"'
      bind -T popup M-g detach
      bind -T popup M-n detach
      bind -T popup M-t detach
      # This lets us do scrollback and search within the popup
      bind -T popup C-[ copy-mode
      set-option -g default-shell ${shell}
    '';

  sessioniser = import ./sessioniser.nix {
    inherit lib pkgs fzf targets;
  };

  popup = import ./popup.nix {inherit pkgs;};
  vcs-popup = import ./vcs-popup.nix {inherit pkgs lib jjui lazygit;};
  notes-popup = import ./notes-popup.nix {inherit lib pkgs;};

  plugins = with pkgs.tmuxPlugins; [
    vim-tmux-navigator
    sensible
    yank
  ];
in
  mkTmuxConfig {
    inherit pkgs plugins extra-config;
  }
