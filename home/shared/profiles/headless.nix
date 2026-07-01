{ config, pkgs, lib, inputs, ... }:

# Shared "headless nyx host" profile.
#
# Enables the shell + dev + CLI-AI subset of nyx.modules and nothing else.
# No desktop / app / sdr modules — those are for GUI hosts. No GPG.
# nyx.secrets.* is not imported into standalone home-manager (matches
# prometheus / L242731 behavior).
#
# Used by: DGX hosts (castor, pollux).

{
  programs.home-manager.enable = true;
  programs.man.enable = true;
  manual.manpages.enable = true;

  home = {
    stateVersion = "26.05";
    packages = with pkgs; [
      rustup
      vhs
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
      yubikey-manager
      libfido2
    ];
  };

  nyx.modules = {
    ai = {
      launcher.enable = true;
      claude = { enable = true; package = null; };
      chatgpt.enable = false;
      gemini.enable  = false;
      ollama.enable  = false;
    };

    dev = {
      cc.enable     = true;
      rust.enable   = true;
      go.enable     = true;
      dhall.enable  = true;
      lua.enable    = true;
      nix.enable    = true;
      node.enable   = true;
      python.enable = true;
    };

    shell = {
      awscliv2.enable     = false;
      azurecli            = { enable = true; loginBrowser = "firefox"; };
      bash.enable         = true;
      bat.enable          = true;
      direnv.enable       = true;
      etcd.enable         = true;
      eza.enable          = true;
      fastfetch.enable    = true;
      fzf.enable          = true;
      gcp.enable          = true;
      git                 = { enable = true; signing.signByDefault = false; };
      glow.enable         = true;
      homelabTools.enable = true;
      jq.enable           = true;
      k8sTooling.enable   = true;
      lazygit.enable      = true;
      lf                  = { enable = true; ueberzugppPackage = null; };
      lmSensors.enable    = true;
      navi.enable         = true;
      ncdu.enable         = true;
      networking.enable   = true;
      nixvim.enable       = true;
      openssl.enable      = true;
      ranger.enable       = true;
      starship.enable     = true;
      terraform.enable    = true;
      tmux.enable         = true;
      usbutils.enable     = true;
      xdg.enable          = true;
      yq.enable           = true;
      zellij.enable       = true;
      zoxide.enable       = true;
      zsh.enable          = true;

      # newer tools
      atuin.enable        = true;
      bandwhich.enable    = true;
      bottom.enable       = true;
      dysk.enable         = true;

      # deliberately off (no display / no value headless)
      mcfly.enable             = false;
      lorri.enable             = false;
      wal.enable               = false;
      ambxstColorBridge.enable = false;
      ytmPlayer.enable         = false;
      weechat.enable           = false;
      astroterm.enable         = false;

      # deliberately absent: gnupg (GPG dropped entirely for headless hosts)
    };

    # desktop.*, app.*, sdr.* — intentionally not enabled
  };
}
