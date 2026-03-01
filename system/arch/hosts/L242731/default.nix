{ config, pkgs, lib, ... }:

{
  programs.home-manager.enable = true;
  programs.man.enable = true;
  manual.manpages.enable = true;

  home = {
    stateVersion = "26.05";
    packages = with pkgs; [
      rustup
      vhs
      gnupg
      ripgrep
      fd
      sd
      dua
      just
      comma
      nix-index
      tuxmux
      wget
      vim
    ];
  };

  nyx.modules = {
    desktop = {
      hypr.enable = true;
    };
    ai = {
      chatgpt.enable = false;
      gemini.enable = true;
      claude.enable = true;
    };
    app = {      
      alacritty = {
        enable = true;
        package = null;
      };
      chromium.enable = true;
      chrome = {
        enable = true;
        makeDefaultBrowser = true;
      };
      kitty = {
        enable = true;
        package = null;
      };
      discord.enable = true;
      firefox.enable = true;
      obs.enable = true;
      obsidian = {
        enable = true;
        package = null;
      };
      scrcpy = {
        enable = true;
        package = null;
      };
      wezterm = {
        enable = true;
        package = null;
      };
      vscode.enable = true;
    };
    dev = {
      androidSDK.enable = true;
      cc.enable = true;
      rust.enable = true;
      go.enable = true;
      dhall.enable = true;
      lua.enable = true;
      nix.enable = true;
      node.enable = false;
      python.enable = true;
    };
    shell = {
      awscliv2.enable = false;
      azurecli.enable = true;
      bash.enable = true;
      bat.enable = true;
      direnv.enable = true;
      etcd.enable= true;
      eza.enable = true;
      fzf.enable = true;
      gcp.enable = true;
      git = {
        enable = true;
        signing.signByDefault = false;
      };
      gnupg = {
        enable = true;
        enableService = pkgs.stdenv.hostPlatform.isLinux;
        publicKeys = [{
          key = ../../../../home/config/.gnupg/public.key;
        }];
      };
      jq.enable = true;
      k8sTooling.enable = true;
      lf.enable = true;
      lorri.enable = false;
      mcfly.enable = true;
      neofetch.enable = true;
      nixvim.enable = true;
      networking.enable = true;
      openssl.enable = true;
      starship.enable = true;
      terraform.enable = true;
      tmux.enable = true;
      wal.enable = true;
      usbutils.enable = true;
      xdg.enable = true;
      yq.enable = true;
      zellij.enable = true;
      zsh.enable = true;
    };
  };
}
