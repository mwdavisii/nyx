{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.nyx.modules.gaming.lutris;
  #android-sdk = inputs.android-nixpkgs.hmModule;
in
{
  options.nyx.modules.gaming.lutris = {
    enable = mkEnableOption "Lutris Configuration";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          lutris
        ];
    };
  };
}
