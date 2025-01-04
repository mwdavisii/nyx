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
      availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ ];
      luks.devices."luks-031e3e0a-58aa-4f51-a1ee-73ec72f43778".device = "/dev/disk/by-uuid/031e3e0a-58aa-4f51-a1ee-73ec72f43778";
    };
    kernelModules = [ "kvm-intel" ];
    #extraModulePackages = [ ];
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
        default = "saved";
      };
    };
  };
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
