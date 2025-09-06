{ config, lib, pkgs, modulesPath, ... }:

{

  fileSystems."/" =
    { device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };

  swapDevices =
    [ ];
}
