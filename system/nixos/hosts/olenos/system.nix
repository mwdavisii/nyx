{ config, lib, pkgs, modulesPath, hostName, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware.nix
    ];

  #networking.hostName = $hostName; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;
  #nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # Enable networking
  # networking.wireless.enable  = lib.mkForce false;1@
  networking.networkmanager.enable = lib.mkForce true;
  networking.useDHCP = lib.mkDefault true;

  environment.variables = {
    NIXOS_OZONE_WL = "1";
    PATH = [
      "\${HOME}/.local/bin"
      "\${HOME}/.config/rofi/scripts"
    ];
    NIXPKGS_ALLOW_UNFREE = "1";
    #PKG_CONFIG_PATH = lib.makeLibraryPath [ libevdev ];
  };
  # Configure keymap in X11
  services = {
    libinput.enable = true;
    xserver = {
      enable = true;
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

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
  };
}
