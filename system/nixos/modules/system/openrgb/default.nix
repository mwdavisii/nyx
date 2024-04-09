{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let
  cfg = config.nyx.modules.system.openrgb;
in
{
  options.nyx.modules.system.openrgb = {
    enable = mkEnableOption "openvpn Settings";
  };

  config = mkIf cfg.enable {
    services.hardware.openrgb.enable = true;
    environment.systemPackages = with pkgs; [
      libevdev
      openrgb
    ];
  };
}
