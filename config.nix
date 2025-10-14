{
  pkgs,
  lib,
  targets ? [],
  bash ? pkgs.bash,
  shell ? "${lib.getExe bash}",
  fzf ? pkgs.fzf,
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
      bind -n C-f run-shell "tmux neww ${getExe sessioniser}"
      bind -n M-t display-popup -E -w 75% -h 75% -b rounded -T "  | Terminal " "${getExe popup}"
      bind -n M-g display-popup -E -w 75% -h 75% -b rounded -T "  | VCS " "${getExe lazyjj-popup}"
      bind -n M-n display-popup -E -w 75% -h 75% -b rounded -T "  | Notes " "${getExe notes-popup}"
      bind -T popup M-t detach
      bind -T popup M-g detach
      bind -T popup M-n detach
      # This lets us do scrollback and search within the popup
      bind -T popup C-[ copy-mode
      set-option -g default-shell ${shell}
    '';

  sessioniser = import ./sessioniser.nix {
    inherit lib pkgs fzf targets;
  };

  popup = import ./popup.nix {inherit pkgs;};
  lazyjj-popup = import ./lazyjj-popup.nix {inherit pkgs lib;};
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
