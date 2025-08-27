{ config, lib, pkgs, modulesPath, hostName, ... }:
{

  imports =
    [
      # Include the results of the hardware scan.
      ./hardware.nix

    ];
  config = {
    networking.networkmanager.enable = lib.mkForce true;
    networking.useDHCP = lib.mkDefault true;
    time.hardwareClockInLocalTime = true;
    # Configure keymap in X11
    services = {
      libinput.enable = false;
      xserver = {
        enable = false;
        videoDrivers = [ "amdgpu" ];
        xkb = {
          layout = "us";
          variant = "";
        };
      };
      printing.enable = false;
      openssh.enable = true;
      gvfs.enable = false; # Mount, trash, and other functionalities
      tumbler.enable = true;
      pipewire = {
        enable = false;
        alsa.enable = false;
        alsa.support32Bit = false;
        pulse.enable =false;
      };
    };

    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;Q

    xdg.portal = {
      enable = false;
      wlr.enable = false;
      config.common.default = "*";
    };
  };
}
