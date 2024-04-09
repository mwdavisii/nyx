{ config, lib, pkgs, modulesPath, hostName, ... }:

{
  config = {
    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [
      xfce.thunar #file explorer
      wget
      zsh
      wlr-randr
      gnumake
      catimg
      curl
      pavucontrol
      networkmanagerapplet
      grim
      slurp
      wl-clipboard
      pamixer
      mpc-cli
      tty-clock
      playerctl
    ];
  };
}

