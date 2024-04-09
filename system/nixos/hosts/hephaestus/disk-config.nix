{ config, lib, pkgs, modulesPath, inputs, ... }:
{
  fileSystems."/" ={ 
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
  };

  fileSystems."/boot" =  { 
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
  };

  swapDevices =[ 
    { 
      device = "/dev/disk/by-label/swap"; 
    }
  ];
}
