{ config, lib, pkgs, modulesPath, inputs, ... }:
{
    fileSystems."/boot" =
      { 
        device = "/dev/disk/by-uuid/CF98-8911";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    swapDevices =
    [ 
      { device = "/dev/disk/by-uuid/107dd2cc-0ed8-4bbd-9546-05a13d69b41b"; }
    ];
}
