{ config, lib, pkgs, modulesPath, inputs, ... }:
{
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/e48e997b-bec8-4e94-abd7-ff215ed757b9";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0607-57CF";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/941a7011-91bf-4ea2-90d3-b72c0c701e71"; }
    ];
}