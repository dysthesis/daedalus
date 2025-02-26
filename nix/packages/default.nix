{
  inputs,
  lib,
  pkgs,
  ...
}: let
  config = import ../../config.nix {inherit lib pkgs inputs;};
in rec {
  default = daedalus;
  daedalus = pkgs.tmux.overrideAttrs (prev: {
    buildInputs = (prev.buildInputs or []) ++ [pkgs.makeWrapper];
    postInstall =
      (prev.postInstall or "")
      +
      /*
      sh
      */
      ''
        mkdir $out/libexec
        mv $out/bin/tmux $out/libexec/tmux-unwrapped
        makeWrapper $out/libexec/tmux-unwrapped $out/bin/tmux \
        	--add-flags "-f ${config}"
          --set TERM "screen-256color"
      '';
  });
}
