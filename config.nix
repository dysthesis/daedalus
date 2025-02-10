{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.babel.tmux) mkTmuxConfig;
  inherit (builtins) readFile;

  extra-config = readFile ./tmux.conf;
  plugins = with pkgs.tmuxPlugins; [
    vim-tmux-navigator
  ];
in
  mkTmuxConfig {
    inherit pkgs plugins extra-config;
  }
