{ config, lib, pkgs, modulesPath, hostname, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware.nix
    ];

  networking.hostName = lib.mkForce hostname; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;
  # Enable networking
  #networking.wireless.enable  = lib.mkForce true;
  networking.networkmanager.enable = lib.mkForce true;
  networking.useDHCP = lib.mkDefault true;
  # Configure keymap in X11cccccbkbkjgclckdehngeerehkdvvleuldgtnfuvutvt
  
  environment.variables = {
    NIXOS_OZONE_WL = "1";
    PATH = [
      "\${HOME}/.local/bin"
      "\${HOME}/.config/rofi/scripts"
    ];
    NIXPKGS_ALLOW_UNFREE = "1";
    #PKG_CONFIG_PATH = lib.makeLibraryPath [ libevdev ];
  };

  services = {
    libinput.enable = true;
    #i18n.consoleUseXkbConfig = true;
    xserver = {
      videoDrivers = [ "modesetting" ];
      enable = true;
      xkb = {
        layout = "us,us";
        variant = ",colemak";
        options = "grp:alt_shift_toggle";
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
      wireplumber.enable = true;
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
  };
}
