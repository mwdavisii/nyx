{ config, lib, pkgs, ... }:
with lib;
let cfg = config.nyx.modules.system.bluetooth;
in
{
  options.nyx.modules.system.bluetooth = { 
    enable = mkEnableOption "Bluetooth Settings"; 
  };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    hardware.bluetooth.package = pkgs.bluez;
    hardware.bluetooth.powerOnBoot = true;
  };
}