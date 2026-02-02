{
  inputs,
  lib,
  pkgs,
  ...
}: let
  mkTmux = {
    shell ? "${lib.getExe pkgs.bash}",
    fzf ? pkgs.fzf,
    jjui ? pkgs.jjui,
    lazygit ? pkgs.lazygit,
    targets ? [],
    ...
  }: let
    config = shell:
      import ../../config.nix {
        inherit
          lib
          pkgs
          inputs
          shell
          fzf
          jjui
          lazygit
          targets
          ;
      };
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
  daedalus = lib.makeOverridable mkTmux {
    shell = "${lib.getExe pkgs.bash}";
    targets = [
      "~/Documents/Projects/"
      "~/Documents/University/"
    ];
  };
}
