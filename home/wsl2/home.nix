{ config, pkgs, ... }:

{
  # Manage home-manager with home-manager (inception)
  programs.home-manager.enable = true;
  # Install man output for any Nix packages.
  programs.man.enable = true;

  manual.manpages.enable = true;
  
  home = {      
    stateVersion = "23.11";
    packages = with pkgs; [
      rustup
      vhs
      bat
      bash
      coreutils-full
      moreutils
      ripgrep
      gnupg
      fd
      sd
      dua
      vhs
      just
      comma
      nix-index
      tuxmux
      zsh
      kubectl
      fluxcd
      wget
      vim
    ];
  };

  nyx.modules = {
    secrets = {
        awsSSHKeys.enable = false;
        awsConfig.enable = true;
        userSSHKeys.enable = true;
        userPGPKeys.enable = true;
    };
    app = {
      alacritty = {
        enable = false;
        package = null;
      };
      kitty.enable = false;
      discord.enable = false;
      firefox.enable = false;
      obs.enable = true;
      wezterm = {
        enable = false;
        package = null;
        fontSize = 14;
      };
    };
    dev = {
      cc.enable = true;
      rust.enable = true;
      go.enable = true;
      dhall.enable = true;
      lua.enable = true;
      nix.enable = true;
      node.enable = true;
      python.enable = true;
    };
    shell = {
      awscliv2.enable = true;
      bash.enable = true;
      bat.enable = true;
      direnv.enable = true;
      eza.enable = true;
      fzf.enable = true;
      gcp.enable = true;
      git = {
        enable = true;
        signing.signByDefault = false;
      };
      gnupg = {
        enable = true;
        enableService = true;
        publicKeys = [{
            key = ../config/.gnupg/public.key;
          }];
      };
      jq.enable = true;
      k8sTooling.enable = true;
      lf.enable = true;
      lorri.enable = false;
      mcfly.enable = true;
      neovim.enable = true;
      networking.enable = true;
      nushell.enable = true;
      starship.enable = true;
      terraform.enable = true;
      tmux.enable = true;
      vale.enable = true;
      xdg.enable = true;
      zellij.enable = true;
      zsh.enable = true;
    };
  };
}
