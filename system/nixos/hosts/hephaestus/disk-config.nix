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
  
  fileSystems."/home/mwdavisii/nix-games" =
  { device = "/dev/disk/by-uuid/4c8d94e1-1354-488e-b0c1-c97674991237";
    fsType = "ext4"; # or "exfat"
    options = [ "defaults" "nofail" ]; # 'nofail' allows boot without drive
  };


  swapDevices =[ 
    { 
      device = "/dev/disk/by-uuid/9e377beb-b0fb-4aa0-aacd-6cbf61f4e89a"; 
    }
  ];
}

