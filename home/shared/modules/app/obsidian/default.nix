{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.obsidian;
in
{
  options.nyx.modules.app.obsidian = {
    enable = mkEnableOption "obsidian";
  };

  config = mkIf cfg.enable {
    # go ahead and install adb here since it's required
    home.packages = with pkgs; [
        obsidian
    ];
  };
}



