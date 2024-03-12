{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    rustup
    vhs
    coreutils-full
    gnupg
    moreutils
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
  home.stateVersion = "23.11";
  # Manage home-manager with home-manager (inception)
  programs.home-manager.enable = true;

  # Install home-manager manpages.
  manual.manpages.enable = true;

  # Install man output for any Nix packages.
  programs.man.enable = true;
  
  nyx.modules = {
    secrets = {
        awsKeys.enable = false;
        awsConfig.enable = true;
        userKeys.enable = true;
    };
    app = {
      alacritty = {
        enable = true;
        package = null;
      };
      kitty.enable = true;
      discord.enable = true;
      firefox.enable = false;
      obs.enable = false;
      wezterm = {
        enable = true;
        package = null;
        fontSize = 14;
      };
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
      git.enable = true;
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