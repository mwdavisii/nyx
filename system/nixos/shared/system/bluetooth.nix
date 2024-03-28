{ config, lib, pkgs, modulesPath, hostName, ... }:
  {
      #Garbage colector
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    # these 2 options below were not mentioned in wiki
    hardware.bluetooth.package = pkgs.bluez;
    hardware.bluetooth.powerOnBoot = true;
  }