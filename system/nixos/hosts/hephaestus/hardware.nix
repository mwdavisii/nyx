{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  imports = [
    (./disk-config.nix)
    (modulesPath + "/installer/scan/not-detected.nix")
   ];
       # Bootloader.
    boot = {
        kernelPackages = pkgs.linuxPackages_latest;
        initrd = {
            availableKernelModules = [ "ata_piix" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
            kernelModules = [ "amdgpu" ];
        };
        kernelModules = [ "amdgpu" ];
        #extraModulePackages = [ ];
        loader = {
        #systemd-boot.enable = true;
        #efi.canTouchEfiVariables = true;
        };
    };
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}