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
    ai ={
	chatgpt.enable = true;
	gemini.enable = true;
	claude.enable = true;
    };
    desktop = {
      wallpaper.enable = true;
      hammerspoon.enable = true;
      karabiner.enable = true;
      amethyst.enable = false; #amethyst is installed by brew cask, this copies config files
      aerospace.enable = true; #aerospace is installed by brew cask, this copies config files
      sketchybar.enable = true; #sketchybar is installed by brew, this copies config files
      darwinColorBridge.enable = true;
    };
    app = {
      iterm2.enable = true;
      alacritty.enable = true;
      finicky.enable = true;
      kitty.enable = true;
      discord.enable = true;
      #signal.enable = true;
      #firefox.enable = true;
      obs.enable = false;
      scrcpy.enable = true;
      wezterm = {
        enable = true;
        package = null;
        fontSize = 14;
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
      nix.enable = false;
      node.enable = false;
      python.enable = true;
    };
    shell = {
      awscliv2.enable = false;
      azurecli.enable = true;
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
      glow.enable = true;
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
      mcfly.enable = false;        # replaced by atuin
      fastfetch.enable = true;
      nixvim.enable = true;
      networking.enable = true;
      openssl.enable = true;
      ranger.enable = true;
      starship.enable = true;
      terraform.enable = true;
      tmux.enable = true;
      wal.enable = true;
      xdg.enable = true;
      yq.enable = true;
      zellij.enable = true;
      zoxide.enable = true;
      zsh.enable = true;
      # New shell tools
      astroterm.enable = true;
      atuin.enable = true;
      bandwhich.enable = true;
      bottom.enable = true;
      dysk.enable = true;
      lazygit.enable = true;
      navi.enable = true;
      ncdu.enable = true;
      weechat.enable = true;
    };
  };
}
