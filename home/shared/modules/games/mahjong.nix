{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.nyx.modules.games.mahjong;
  #android-sdk = inputs.android-nixpkgs.hmModule;
in
{
  options.nyx.modules.games.mahjong = {
    enable = mkEnableOption "Android SDK Configuration";
  };

  config = mkIf cfg.enable {
    programs.bash.shellAliases = {
      mahjong = "kmahjongg";
    };

    home = {
      packages = with pkgs;
        [
          libsForQt5.kmahjongg
        ];
    };
  };
}
