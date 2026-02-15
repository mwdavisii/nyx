{ config, lib, pkgs, modulesPath, hostName, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware.nix
      ../../shared/system/locale.nix
      ../../shared/system/gc.nix
      ../../shared/system/login.nix
      ../../shared/system/bluetooth.nix
      ../../shared/system/env-vars-nvidia.nix
      ../../shared/system/opengl.nix

    ];

  #networking.hostName = $hostName; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;
  #nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # Enable networking
  # networking.wireless.enable  = lib.mkForce false;
  networking.networkmanager.enable = lib.mkForce true;
  networking.useDHCP = lib.mkDefault true;


  time.hardwareClockInLocalTime = true;

  environment.systemPackages = with pkgs; [
    libevdev
  ];

  # Configure keymap in X11
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      layout = "us";
      xkbVariant = "";
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
  sound.enable = true;
  hardware.pulseaudio.enable = false;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
  };
}
