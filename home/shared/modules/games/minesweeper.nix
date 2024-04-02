{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.nyx.modules.games.minesweeper;
  #android-sdk = inputs.android-nixpkgs.hmModule;
in
{
  options.nyx.modules.games.minesweeper = {
    enable = mkEnableOption "Android SDK Configuration";
  };

  config = mkIf cfg.enable {
    programs.bash.shellAliases = {
      minesweeper = "kmines";
    };

    home = {
      packages = with pkgs;
        [
          libsForQt5.kmines
        ];
    };
  };
}
