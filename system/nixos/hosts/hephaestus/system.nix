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
      libinput.enable = true;
      xserver = {
        enable = true;
        videoDrivers = [ "amdgpu" ];
        xkb = {
          layout = "us";
          variant = "";
        };
      };
      printing.enable = true;
      openssh.enable = true;
      gvfs.enable = true; # Mount, trash, and other functionalities
      tumbler.enable = true;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };

    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      config.common.default = "*";
    };
  };
}
