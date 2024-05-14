{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  imports = [
    (./disk-config.nix)
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
 hardware.asahi.peripheralFirmwareDirectory = ./firmware; 
 # Bootloader. 
  boot = {
    #extraModulePackages = [ ];
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
      };
    };
  };
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
