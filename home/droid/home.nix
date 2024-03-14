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
      git
      vim
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
/*
  nyx.modules = {
    secrets = {
        awsKeys.enable = false;
        awsConfig.enable = false;
        userKeys.enable = true;
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
      cc.enable = false;
      rust.enable = false;
      go.enable = true;
      dhall.enable = false;
      lua.enable = true;
      nix.enable = true;
      node.enable = false;
      python.enable = false;
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
      };
      jq.enable = true;
      k8sTooling.enable = true;
      lf.enable = false;
      lorri.enable = false;
      mcfly.enable = false;
      neovim.enable = true;
      networking.enable = true;
      nushell.enable = false;
      starship.enable = true;
      terraform.enable = false;
      tmux.enable = true;
      vale.enable = false;
      xdg.enable = true;
      zellij.enable = false;
      zsh.enable = true;
    };
  };
  */
}
