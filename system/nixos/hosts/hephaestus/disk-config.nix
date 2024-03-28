{ config, lib, pkgs, modulesPath, inputs, ... }:
{
fileSystems."/" =
    { device = "/dev/disk/by-uuid/155193bb-865d-4295-8aee-728af878243e";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/2275-59D6";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/e00f254f-af03-4efa-af3b-a8931734960a"; }
    ];
}
