{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let cfg = config.nyx.modules.system.yabai;
in
{
  options.nyx.modules.system.yubikey = { enable = mkEnableOption "yubikey app"; };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubikey-personalization
      libfido2
    ];
  };
}

