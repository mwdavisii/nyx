{ config, lib, pkgs, modulesPath, inputs, ... }:

{
    imports =
    [ 
        (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "" ];
  boot.extraModulePackages = [ ];
}

