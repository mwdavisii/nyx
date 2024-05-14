{ config, lib, pkgs, modulesPath, ... }:

{

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/13aa135e-d7bf-41e8-9616-9c71bb3d9461";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0414-1AFF";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ ];

}
