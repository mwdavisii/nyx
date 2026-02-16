{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let cfg = config.nyx.modules.system.openvpn;
in
{
  options.nyx.modules.system.openvpn = {
    enable = mkEnableOption "openvpn Settings";
  };

  config = mkIf cfg.enable {

    programs.openvpn3.enable = true;
    environment.systemPackages = with pkgs; [
      libevdev
      openssl
    ];
  };
}
