{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ./disk-config.nix
   ];

  boot = {
    initrd = {
        availableKernelModules = [ "ata_piix" "ahci" "sd_mod" "sr_mod" ];
        initrd.kernelModules = [ ];
    };
    kernelModules = [ ];
    extraModulePackages = [ ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
   

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/466a545c-d51f-4154-8dee-263b4c1ae339";
      fsType = "ext4";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  virtualisation.virtualbox.guest.enable = true;

}
