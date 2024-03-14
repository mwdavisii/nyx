{ config, lib, pkgs, ... }:

{  
      home.packages = with pkgs;
        [ 
          zsh
          nix-zsh-completions
        ];

      home.file.".zshenv".source = ../../../config/.zshenv;
      xdg.configFile."zsh".source = ../../../config/.config/zsh;
}