{ agenix, config, pkgs, userConf, inputs, hostname, ... }: 
with pkgs;
with userConf;
{
  #secrets config
  nyx.modules = {
    secrets = {
        enable = true;
        awsKeys.enable = false;
        awsConfig.enable = true;
        userKeys.enable = true;
    };
  };

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    wslConf.interop.appendWindowsPath = false;
    wslConf.network.generateHosts = false;
    defaultUser = userName;
    startMenuLaunchers = true;
    docker-desktop.enable = false;
  };


  time.timeZone = "America/Chicago";
  networking.hostName = "${hostname}";
  systemd.tmpfiles.rules = [
    "d /home/${userName}/.config 0755 ${userName} users"
    "d /home/${userName}/.config/lvim 0755 ${userName} users"
  ];

  system.stateVersion = "23.11";
  programs.zsh.enable = true;
  environment.pathsToLink = ["/share/zsh/"];
  environment.shells = [pkgs.zsh];
  environment.enableAllTerminfo = true;
  security.sudo.wheelNeedsPassword = false;

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

  fonts.packages = with pkgs; [
    dejavu_fonts
    jetbrains-mono
    font-awesome
    noto-fonts
    noto-fonts-emoji
  ];

  # Load configuration that is shared across systems
  #environment.systemPackages = with pkgs; [
  #] ++ (import ../../home/shared/packages.nix { inherit pkgs ; });
}