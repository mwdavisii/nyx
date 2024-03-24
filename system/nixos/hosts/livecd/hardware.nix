{ config, lib, pkgs, modulesPath, inputs, ... }:

{

  boot = {
    initrd = {
        availableKernelModules = [ "ata_piix" "ahci" "sd_mod" "sr_mod" ];
        kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    #extraModulePackages = [ ];
    loader = {
      #systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
