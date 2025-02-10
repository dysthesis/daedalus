{
  inputs,
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
    '';

  sessioniser = import ./sessioniser.nix {
    inherit lib pkgs;
    targets = [
      "~/Documents/University"
      "~/Documents/Projects"
    ];
  };
  plugins = with pkgs.tmuxPlugins; [
    rose-pine
    vim-tmux-navigator
    sensible
    yank
    # {plugin = inputs.minimal-tmux.packages.${pkgs.system}.default;}
  ];
in
  builtins.trace "Config is\n${extra-config}"
  mkTmuxConfig {
    inherit pkgs plugins extra-config;
  }
