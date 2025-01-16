{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.opentofu;
in
{
  options.nyx.modules.shell.opentofu = {
    enable = mkEnableOption "terraform configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        opentofu
      ];
  };
}
