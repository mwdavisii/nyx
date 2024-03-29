{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  imports = [
    (./disk-config.nix)
    (modulesPath + "/installer/scan/not-detected.nix")
   ];
   
       # Bootloader.
    boot = {
        kernelPackages = pkgs.linuxPackages_latest;
        initrd = {
            availableKernelModules = [ "ata_piix" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
            kernelModules = [ "nvidia" ];
        };
        kernelModules = [ "nvidia" ];
        #extraModulePackages = [ ];
        loader = {
            efi.canTouchEfiVariables = true;
            grub = {
                enable = true;
                devices = [ "nodev" ];
                efiSupport = true;
                useOSProber = true;
            };
        };
    };
    # https://nixos.wiki/wiki/Nvidia
    hardware.nvidia = {
        #prime = {
        #    sync.enable = true;
        #    intelBusId = "PCI:0:2:0";
        #    nvidiaBusId = "PCI:14:0:0"; 
        #};
        # Modesetting is required.
        modesetting.enable = true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        # Enable this if you have graphical corruption issues or application crashes after waking
        # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
        # of just the bare essentials.
        powerManagement.enable = false;

        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = false;

        # Use the NVidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of 
        # supported GPUs is at: 
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
        # Only available from driver 515.43.04+
        # Currently alpha-quality/buggy, so false is currently the recommended setting.
        open = false;

        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}