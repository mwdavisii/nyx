{ config, lib, pkgs, modulesPath, ... }:

{

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/7128fcc8-c42e-415d-9120-e3d94c187a84";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/99142043-ba9d-4bf5-9111-0b61ff558e42"; }
    ];
}