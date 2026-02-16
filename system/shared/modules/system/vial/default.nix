{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let cfg = config.nyx.modules.system.vial;
in
{
  options.nyx.modules.system.vial = { 
    enable = mkEnableOption "vial"; 
  };
  config = mkIf cfg.enable {
    services.udev.extraRules =
      ''
        #Vial user access to dev/hidraw
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
      '';
  };
}