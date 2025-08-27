{ config, lib, pkgs, modulesPath, ... }:

{

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/740f9f95-591a-4dde-8a89-ccb0f11b2bdc";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/2f8d3431-3f2d-4858-9046-bfec49d2b363"; }
    ];
}