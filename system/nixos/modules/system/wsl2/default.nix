{ config, lib, userConf, inputs, hostname, ... }: 
with userConf;
with lib;
let
  nixConf = import ../../../nix/conf.nix;
  cfg = config.nyx.modules.system.wsl2;
in
{
  options.nyx.modules.system.wsl2 = { 
    enable = mkEnableOption "WSL2 System Config"; 
  };

  config = mkIf cfg.enable {
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
    system.stateVersion = "24.11";
    programs.zsh.enable = true;
    time.timeZone = "America/Chicago";
    networking.hostName = "${hostname}";
    systemd.tmpfiles.rules = [
      "d /home/${userName}/.config 0755 ${userName} users"
      "d /home/${userName}/.config/lvim 0755 ${userName} users"
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
  };
}