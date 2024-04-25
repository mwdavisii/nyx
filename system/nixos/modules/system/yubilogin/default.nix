{ config, lib, pkgs, modulesPath, hostName, userConf, ... }:
with lib;
let cfg = config.nyx.modules.system.yubilogin;
in
{
  options.nyx.modules.system.yubilogin = {
    enable = mkEnableOption "Bluetooth Settings";
  };

  config = mkIf cfg.enable {
    services.pcscd.enable = true;
    security = {
      pam.yubico = {
        enable = true;
        mode = "challenge-response";
        id = userConf.yubiKeySerials;
      };
    };
    services.udev.packages = [ pkgs.yubikey-personalization ];
  };
}
