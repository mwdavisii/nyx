{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.nyx.modules.gaming.mahjong;
  #android-sdk = inputs.android-nixpkgs.hmModule;
in
{
  options.nyx.modules.gaming.mahjong = {
    enable = mkEnableOption "Mahjong Configuration";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          libsForQt5.kmahjongg
        ];
    };
  };
}
