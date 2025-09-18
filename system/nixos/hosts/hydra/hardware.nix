{ config, lib, pkgs, modulesPath, inputs, ... }:

{
    imports =
    [ 
        (modulesPath + "/profiles/qemu-guest.nix")
        (./disk-config.nix)
    ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ " kvm" "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  virtualisation.libvirtd.enable = true;
}