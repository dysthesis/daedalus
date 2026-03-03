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

      # Load tmux plugins asynchronously to avoid blocking server start
      run-shell -b "${pkgs.tmuxPlugins.vim-tmux-navigator}/share/tmux-plugins/vim-tmux-navigator/vim-tmux-navigator.tmux"
      run-shell -b "${pkgs.tmuxPlugins.sensible}/share/tmux-plugins/sensible/sensible.tmux"
      run-shell -b "${pkgs.tmuxPlugins.yank}/share/tmux-plugins/yank/yank.tmux"

      # Inline minimal Rosé Pine (lackluster) theme to remove runtime shell script overhead
      set -g status on
      set -g status-style "fg=#799B78,bg=default"
      set -g message-style "fg=#555555,bg=default"
      set -g message-command-style "fg=#191919,bg=#FFAA88"
      set -g pane-border-style "fg=#555555"
      set -g pane-active-border-style "fg=#FFAA88"
      set -g display-panes-active-colour "#FFFFFF"
      set -g display-panes-colour "#FFAA88"
      setw -g window-status-style "fg=#7788AA,bg=default"
      setw -g window-status-activity-style "fg=#DEEEED,bg=default"
      setw -g window-status-current-style "fg=#FFAA88,bg=default"
      setw -g window-status-separator "  "
      setw -g clock-mode-colour "#eb6f92"
      setw -g mode-style "fg=#FFAA88"
      set -g status-left-length 200
      set -g status-right-length 200
      set -g status-left " #[fg=\#{?client_prefix,#D70000,#FFFFFF}] #[fg=#FFFFFF]#S #[fg=#7A7A7A] | "
      set -g status-right "#[fg=#7788AA] #[fg=#FFFFFF]#(whoami)#[fg=#7A7A7A] | #[fg=#FFAA88]󰒋 #[fg=#FFFFFF]#H#[fg=#7A7A7A] | #[fg=#708090] #[fg=#DEEEED]\#{b:pane_current_path} "

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

  # Plugin loading handled manually (and asynchronously) in extra-config to avoid
  # blocking startup, so leave mkTmuxConfig plugins empty.
  plugins = [];
in
  mkTmuxConfig {
    inherit pkgs plugins extra-config;
  }
