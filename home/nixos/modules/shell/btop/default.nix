{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.shell.btop;
in
{
  options.nyx.modules.shell.btop = {
    enable = mkEnableOption "Ranger Config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ranger
    ];
    xdg.configFile."btop".source = ../../../../config/.config/btop;
  };
}
