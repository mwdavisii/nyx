{ config, pkgs, lib, inputs, ... }:

{
  programs.home-manager.enable = true;
  programs.man.enable = true;
  manual.manpages.enable = true;

  home = {
    stateVersion = "26.05";

    packages = with pkgs; [
      # Wrapper to launch calibre with system Python (Nix python shadows /usr/bin/python3
      # and lacks python-msgpack which calibre needs)
      (writeShellScriptBin "calibre" ''exec /usr/bin/python3 /usr/bin/calibre "$@"'')
      (writeShellScriptBin "calibredb" ''exec /usr/bin/python3 /usr/bin/calibredb "$@"'')
      (writeShellScriptBin "calibre-server" ''exec /usr/bin/python3 /usr/bin/calibre-server "$@"'')
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
      cava = {
        enable = true;
        package = null; # installed via pacman
      };
      gtk = { enable = true; dconf.enable = false; };
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
      vial.enable = true;
    };
    ai = {
      launcher.enable = true;
      chatgpt.enable = true;
      gemini.enable = true;
      # Haiku-via-Azure-APIM model override is scoped to the APIM session only, applied at
      # launch via `claude --settings` from ~/.claude_haiku_env (CLAUDE_EXTRA_SETTINGS) by the
      # ai launcher. Kept out of settings.json so plain `--model haiku` against the real
      # Anthropic API isn't rewritten to a deployment name it doesn't know.
      claude = { enable = true; package = null; };
      ollama.enable = false; # using pacman ollama-rocm system service instead (see /etc/systemd/system/ollama.service.d/override.conf)
    };
    app = {
      alacritty = {
        enable = true;
        package = null;
      };
      chromium = {
        enable = true;
        package = null; # installed via pacman (extra/chromium) — Nix build has no GPU accel on Arch
      };
      chrome = {
        enable = true;
        package = null; # installed via pacman (AUR/google-chrome) — Nix build has no GPU accel on Arch
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
      streaming = {
        enable = true;
        package = null; # installed via pacman
        primaryMic = "alsa_input.usb-Blue_Microphones_Yeti_Stereo_Microphone_797_2021_02_02_48276-00.analog-stereo";
        deprioritizeMic = "alsa_input.usb-046d_Logitech_StreamCam_2F9E86A5-02.analog-stereo";
        outputDevice = "alsa_output.pci-0000_0a_00.0.iec958-ac3-surround-51";
        litra = {
          enable = true;
          brightness = 30;
          temperature = 4000;
        };
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
      signal = {
        enable = true;
        package = null; # installed via pacman
      };
      vscode.enable = true;
      pearDesktop.enable = true;
      opencode = {
        enable = true;
        package = null; # installed via pacman/AUR
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
      qmk.enable = true;
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
      azurecli = {
        enable = true;
        loginBrowser = "firefox";
      };
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
      ambxstColorBridge.enable = true;
      ytmPlayer = { enable = true; package = null; }; # installed via pacman (needs python-dbus-fast for MPRIS support)
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
      homelabTools.enable = true;
      weechat.enable = true;
    };
  };

  services.swaync.enable = lib.mkForce false;
}
