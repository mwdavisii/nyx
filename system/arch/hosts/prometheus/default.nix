{ config, pkgs, lib, inputs, ... }:

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
      wl-clip-persist
      yubikey-manager
    ];
  };

  nyx.modules = {
    desktop = {
      gtk.enable = true;
      cava = {
        enable = true;
        package = null; # installed via pacman
      };
      gtk.enable = true;
      kanshi.enable = true;
      hypr = {
        enable = true;
        gpuPackages = false;
        plugins = false;
        ttyLaunch = true;
      };
      kmonad = {
        enable = true;
        package = inputs.kmonad.packages.${pkgs.stdenv.hostPlatform.system}.default;
      };
    };
    ai = {
      chatgpt.enable = true;
      gemini.enable = true;
      claude = { enable = true; package = null; };
      ollama.enable = true;
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
      discord = {
        enable = true;
        package = null; # installed via pacman (discord_arch_electron)
      };
      firefox.enable = true;
      obs = {
        enable = true;
        package = null;
      };
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
      pearDesktop.enable = true;
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
    sdr = {
      sdrpp   = { enable = true; package = null; };
      gqrx    = { enable = true; package = null; };
      rtl433.enable  = true;
      readsb.enable  = true;
      analysis.enable = true;
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
      lf = {
        enable = true;
        ueberzugppPackage = null;
      };
      lorri.enable = false;
      mcfly.enable = false;        # replaced by atuin
      fastfetch.enable = true;
      nvtop = { enable = true; package = pkgs.nvtopPackages.amd; };
      ambxstColorBridge.enable = true;
      ytmPlayer = { enable = true; package = null; }; # installed via pacman (has python-dbus-next MPRIS support)
      nixvim.enable = true;
      networking.enable = true;
      openssl.enable = true;
      ranger.enable = true;
      starship.enable = true;
      terraform.enable = true;
      tmux.enable = true;
      wal.enable = true;
      usbutils.enable = true;
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
      lmSensors.enable = true;
      navi.enable = true;
      ncdu.enable = true;
    };
  };

  services.swaync.enable = lib.mkForce false;
}
