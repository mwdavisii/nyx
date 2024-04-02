{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.nyx.modules.gaming.minesweeper;
  #android-sdk = inputs.android-nixpkgs.hmModule;
in
{
  options.nyx.modules.gaming.minesweeper = {
    enable = mkEnableOption "Minesweeper";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          libsForQt5.kmines
        ];
    };
  };
}
