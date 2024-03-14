{ ... }:

{
  imports = [./system.nix];
  
  home = {      
    stateVersion = "23.11";
    packages = with pkgs; [
      rustup
      vhs
      bat
      bash
      coreutils-full
      moreutils
      ripgrep
      gnupg
      fd
      sd
      dua
      vhs
      just
      comma
      nix-index
      tuxmux
      zsh
      kubectl
      fluxcd
      wget
      vim
      git
    ];
  };
  
}