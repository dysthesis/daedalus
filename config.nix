{
  pkgs,
  lib,
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
      ${readFile ./lackluster.tmux}
      bind -n C-f run-shell "tmux neww ${getExe sessioniser}"
      bind -n M-a display-popup -E -w 75% -h 75% -b rounded "${getExe popup}"
      bind -T popup M-a detach
      # This lets us do scrollback and search within the popup
      bind -T popup C-[ copy-mode
    '';

  sessioniser = import ./sessioniser.nix {
    inherit lib pkgs;
    targets = [
      "~/Documents/University"
      "~/Documents/Projects"
    ];
  };
  popup = import ./popup.nix {inherit pkgs;};

  plugins = with pkgs.tmuxPlugins; [
    vim-tmux-navigator
    sensible
    yank
    # {plugin = inputs.minimal-tmux.packages.${pkgs.system}.default;}
  ];
in
  mkTmuxConfig {
    inherit pkgs plugins extra-config;
  }
