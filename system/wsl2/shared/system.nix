{ config, pkgs, userConf, inputs, hostname, ... }: 
with pkgs;
with userConf;
with lib;
let
  nixConf = import ../../../nix/conf.nix;
in
{
  config = {
    wsl = {
      enable = true;
      wslConf.automount.root = "/mnt";
      wslConf.interop.appendWindowsPath = false;
      wslConf.network.generateHosts = false;
      defaultUser = userName;
      startMenuLaunchers = true;
      docker-desktop.enable = false;
    };
    
    services.vscode-server.enable = true;
    environment.shells = [pkgs.zsh];
    system.stateVersion = "23.11";
    programs.zsh.enable = true;
    security.sudo.wheelNeedsPassword = false;
    time.timeZone = "America/Chicago";
    networking.hostName = "${hostname}";
    systemd.tmpfiles.rules = [
      "d /home/${userName}/.config 0755 ${userName} users"
      "d /home/${userName}/.config/lvim 0755 ${userName} users"
    ];
    fonts.packages = with pkgs; [
      dejavu_fonts
      jetbrains-mono
      font-awesome
      noto-fonts
      noto-fonts-emoji
    ];
     # Turn on flag for proprietary software
    nix = {
      nixPath = [
        "nixpkgs=${inputs.nixpkgs.outPath}"
        "nixos-config=/etc/nixos/configuration.nix"
        "/nix/var/nix/profiles/per-user/root/channels"
      ];
      
      settings ={
        trusted-users = [ "${userName}" ];
        accept-flake-config = true;
        #auto-optimize-store = true;
      };
      
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      
      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };

      registry = {
        nixpkgs = {
          flake = inputs.nixpkgs;
        };
      };
    };
     # Don't require password for users in `wheel` group for these commands
    security.sudo = {
      enable = true;
      extraRules = [{
        commands = [
        {
          command = "${pkgs.systemd}/bin/reboot";
          options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }];
    };
  };
}