{ config, pkgs, ... }:

{
  # Manage home-manager with home-manager (inception)
  programs.home-manager.enable = false;
  # Install man output for any Nix packages.
  programs.man.enable = false;
  programs.zsh.enable = false;
  manual.manpages.enable = false;

  home = {
    sessionVariables = {
      PATH = "$PATH:~/.local/bin:~/.config/rofi/scripts";
    };
    stateVersion = "25.05";
  };

  nyx = {
    modules = {
      gaming = {
        bsdgames.enable = false;
        lutris.enable = false;
        mahjong.enable = false;
        minesweeper.enable = false;
        #retroarch.enable = false;
        steam.enable = false;
      };
      desktop = {
        hypr.enable = false;
        rofi.enable = false;
        gtk.enable = false;
        wlogout.enable = false;
        cava.enable = false;
        kmonad.enable = false;
      };
      app = {
        chromium.enable = false;
        guvcview.enable = false;
        alacritty = {
          enable = false;
        };
        kitty.enable = false;
        discord.enable = false;
        firefox.enable = false;
        chrome = {
          enable = false;
          makeDefaultBrowser = false;
        };
        obs.enable = false;
        scrcpy.enable = false;
        qemu.enable = false;
        wezterm = {
          enable = false; #having issue with wezterm and wayland
          package = null;
          fontSize = 14;
        };
        vscode.enable = false;
      };
      dev = {
        androidSDK.enable = false;
        cc.enable = false;
        rust.enable = false;
        go.enable = false;
        dhall.enable = false;
        lua.enable = false;
        nix.enable = false;
        node.enable = false;
        python.enable = false;
      };
      shell = {
        awscliv2.enable = false;
        bash.enable = false;
        bat.enable = false;
        btop.enable = false;
        direnv.enable = false;
        eza.enable = false;
        fzf.enable = false;
        gcp.enable = false;
        git = {
          enable = false;
          signing.signByDefault = false;
        };
        gnupg = {
          enable = false;
          enableService = false;
        };
        jq.enable = false;
        k8sTooling.enable = false;
        lf.enable = false;
        lorri.enable = false;
        mcfly.enable = false;
        neofetch.enable = false;
        neovim.enable = false;
        networking.enable = false;
        openssl.enable = false;
        ranger.enable = false;
        starship.enable = false;
        terraform.enable = false;
        tmux.enable = false;
        usbutils.enable = false;
        xdg.enable = false;
        zellij.enable = false;
        zsh.enable = false;
      };
    };
  };
}
