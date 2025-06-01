{
  inputs,
  lib,
  pkgs,
  ...
}: let
  mkTmux = {
    shell ? "bash",
    fzf ? pkgs.fzf,
    ...
  }: let
    config = shell: import ../../config.nix {inherit lib pkgs inputs shell fzf;};
  in
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
