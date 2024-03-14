{ config, pkgs, ... }:

{
  # Manage home-manager with home-manager (inception)
  programs.home-manager.enable = true;
  home = {      
    stateVersion = "23.11";
    packages = with pkgs; [
      git
      vim
      coreutils
      moreutils
      comma
      zsh
      kubectl
      fluxcd
      k9s
      open-policy-agent
    ];
  };

  nyx.modules = {
    dev = {
      cc.enable = false;
      rust.enable = false;
      go.enable = true;
      dhall.enable = false;
      lua.enable = true;
      nix.enable = true;
      node.enable = false;
      python.enable = false;
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
      lf.enable = false;
      lorri.enable = false;
      mcfly.enable = false;
      neovim.enable = true;
      networking.enable = true;
      nushell.enable = false;
      starship.enable = true;
      terraform.enable = false;
      tmux.enable = true;
      vale.enable = false;
      xdg.enable = true;
      zellij.enable = false;
      zsh.enable = true;
    };
  };
  
}
