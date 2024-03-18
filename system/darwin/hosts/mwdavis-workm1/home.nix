{ config, pkgs, lib, ... }:

{
  programs.home-manager.enable = true;
  programs.man.enable = true;
  manual.manpages.enable = true;

  home = {
    stateVersion = "23.11";
    packages = with pkgs; [
      rustup
      vhs
      gnupg
      ripgrep
      fd
      sd
      dua
      vhs
      just
      comma
      nix-index
      tuxmux
      wget
      vim
    ];
  };
  
  nyx.modules = {
    app = {
      alacritty = {
        enable = true;
        package = null;
      };
      kitty.enable = true;
      discord.enable = true;
      firefox.enable = false;
      obs.enable = false;
      scrcpy.enable = true;
      wezterm = {
        enable = true;
        package = null;
        fontSize = 14;
      };
    };
    dev = {
      androidSDK.enable = true;
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
        enableService = pkgs.hostPlatform.isLinux;
        publicKeys = [{
            key = ../../../../home/config/.gnupg/public.key;
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