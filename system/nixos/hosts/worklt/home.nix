{ config, pkgs, ... }:

{
  # Manage home-manager with home-manager (inception)
  programs.home-manager.enable = true;
  # Install man output for any Nix packages.
  programs.man.enable = true;
  manual.manpages.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4"; # Super key
      output = {
        "Virtual-1" = {
          mode = "1920x1080@60Hz";
        };
      };
    };
  };

  home = {
    stateVersion = "23.11";
    packages = with pkgs; [
      rustup
      vhs
      bat
      bash
      wget
    ];
  };

  nyx = {
    modules = {
      app = {
        alacritty = {
          enable = true;
        };
        kitty.enable = true;
        discord.enable = true;
        firefox.enable = false;
        chrome.enable = true;
        obs.enable = true;
        wezterm = {
          enable = true;
          package = null;
          fontSize = 14;
        };
        vscode.enable = true;
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
        usbutils.enable = true;
        vale.enable = true;
        xdg.enable = true;
        zellij.enable = true;
        zsh.enable = true;
      };
    };
  };
}
