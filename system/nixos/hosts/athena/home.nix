{ config, pkgs, ... }:

{
  # Manage home-manager with home-manager (inception)
  programs.home-manager.enable = true;
  # Install man output for any Nix packages.
  programs.man.enable = true;
  manual.manpages.enable = true;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Tokyonight-Dark-B-LB";
    };
  };

  #wayland.windowManager.sway = {
  #  enable = true;
  #  config = rec {
  #    modifier = "Mod4"; # Super key
  #    output = {
  #      "Virtual-1" = {
  #        mode = "1920x1080@60Hz";
  #      };
  #    };
  #  };
  #};

  home = {
    sessionVariables = {
      PATH = "$PATH:~/.local/bin:~/.config/rofi/scripts";
    };
    stateVersion = "24.11";
  };

  nyx = {
    modules = {
      gaming = {
        bsdgames.enable = true;
        lutris.enable = true;
        mahjong.enable = true;
        minesweeper.enable = true;
        retroarch.enable = true;
        steam.enable = true;
      };
      desktop = {
        hypr.enable = true;
        rofi.enable = true;
        gtk.enable = true;
        wlogout.enable = true;
      };
      app = {
        alacritty = {
          enable = true;
        };
        kitty.enable = true;
        discord.enable = true;
        firefox.enable = true;
        chrome = {
          enable = true;
          makeDefaultBrowser = true;
        };
        obs.enable = true;
        scrcpy.enable = true;
        qemu.enable = true;
        wezterm = {
          enable = false; #having issue with wezterm and wayland
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
        neofetch.enable = true;
        neovim.enable = true;
        networking.enable = true;
        ranger.enable = false; #prefer lf
        starship.enable = true;
        terraform.enable = true;
        tmux.enable = true;
        usbutils.enable = true;
        xdg.enable = true;
        zellij.enable = true;
        zsh.enable = true;
      };
    };
  };
}
