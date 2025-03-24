{
  inputs,
  lib,
  pkgs,
  ...
}: let
  config = shell: import ../../config.nix {inherit lib pkgs inputs shell;};
  mkTmux = {shell ? "bash", ...}:
    pkgs.tmux.overrideAttrs (prev: {
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
          	--add-flags "-f ${config shell}"
        '';
    });
in rec {
  default = daedalus;
  daedalus = lib.makeOverridable mkTmux {shell = "bash";};
}
