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
      bind -n C-f display-popup -E -w 75% -h 75% -b rounded "tmux neww ${getExe sessioniser}"
    '';

  sessioniser = import ./sessioniser.nix {
    inherit lib pkgs;
    targets = [
      "~/Documents/University"
      "~/Documents/Projects"
    ];
  };
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
