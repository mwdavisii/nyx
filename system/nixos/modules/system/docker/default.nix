{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let
  cfg = config.nyx.modules.system.docker;
in
{
  options.nyx.modules.system.docker = {
    enable = mkEnableOption "openvpn Settings";
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    services.hardware.openrgb.enable = true;
    environment.systemPackages = with pkgs; [
      docker
      coreutils
    ];
  };
}
