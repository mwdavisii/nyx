{ config, lib, pkgs, ... }:
let 
    pluginsDir = ".zsh/plugins";
in

{  
      home.packages = with pkgs;
        [ 
          zsh                                   
          nix-zsh-completions
          pkgs.oh-my-zsh
          pkgs.zsh-syntax-highlighting
          pkgs.zsh-history-substring-search
        ];

      home.file.".zshenv".source = ../../config/.zshenv;
      xdg.configFile."zsh".source = ../../config/.config/zsh;
      #home."zsh/nyx_zshrc".text = ''
      #  "source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
      #  "source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"}
      # '';
}