{ config, pkgs, ... }:

{
  # Manage home-manager with home-manager (inception)
  programs.home-manager.enable = true;
  # Install man output for any Nix packages.
  programs.man.enable = true;
  manual.manpages.enable = true;
  programs.zsh.enable = true;

  home = {
    sessionVariables = {
      PATH = "$PATH:~/.local/bin:~/.config/rofi/scripts";
    };
    stateVersion = "24.11";
  };

  nyx = {
    modules = {
      gaming = {
        bsdgames.enable = false; #issue compiling on WSL.
        lutris.enable = true;
        mahjong.enable = true;
        minesweeper.enable = true;
        retroarch.enable = false;
        steam.enable = true;
      };
      desktop = {
        hypr.enable = true;
        rofi.enable = true;
        gtk.enable = true;
        wlogout.enable = true;
        cava.enable = true;
        kmonad.enable = true;
      };
      app = {
        alacritty = {
          enable = true;
        };
        mysql-workbench.enable = true;
        kitty.enable = true;
        discord.enable = true;
        firefox.enable = true;
        jupyter.enable = true;
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
        python.enable = false; #conflict w/ Jupyter
      };
      shell = {
        awscliv2.enable = true;
        bash.enable = true;
        bat.enable = true;
        btop.enable = true;
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
          enableSSHSupport = true;
        };
        jq.enable = true;
        k8sTooling.enable = true;
        lf.enable = true;
        lorri.enable = false;
        mcfly.enable = true;
        neofetch.enable = true;
        neovim.enable = true;
        networking.enable = true;
        ranger.enable = false;
        starship.enable = true;
        terraform.enable = true;
        tmux.enable = true;
        usbutils.enable = true;
        wal.enable = true;
        xdg.enable = true;
        zellij.enable = true;
        zsh.enable = true;
      };
    };
  };
}
