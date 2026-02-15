{ config, lib, pkgs, modulesPath, inputs, ... }:
{
  fileSystems."/" ={ 
      device = "/dev/disk/by-uuid/a465158e-20e5-45f4-b6f0-693dea33e650";
      fsType = "ext4";
  };

  fileSystems."/boot" =  { 
      device = "/dev/disk/by-uuid/5FC2-A833";
      fsType = "vfat";
  };

  swapDevices =[ 
    { 
      device = "/dev/disk/by-uuid/9e377beb-b0fb-4aa0-aacd-6cbf61f4e89a"; 
    }
  ];
}

