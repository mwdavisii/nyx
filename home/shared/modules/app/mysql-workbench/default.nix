{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.mysql-workbench;
in
{
  options.nyx.modules.app.mysql-workbench = {
    enable = mkEnableOption "MySQL Workbench";
  };

  config = mkIf cfg.enable {
    # go ahead and install adb here since it's required
    home.packages = with pkgs; [
      mysql-workbench
    ];
  };
}




