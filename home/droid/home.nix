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
      jq 
      k9s
      fluxcd
      kubectl
      kustomize
      flux
      open-policy-agent
      awscli2
      eza
      starship
      neovim
      marksman
      nodejs
      gcc
      clang-tools
      cmakeCurses
      cmake-format
      gnumake
      ninja
      zsh-syntax-highlighting
      zsh-autosuggestions
      fzf
      zellij
    ];
    #files
  };
    xdg.configFile."zellij".source = ../config/.config/zellij;
    #gpg
    programs.gpg = {
      enable = true;
      settings = {
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        default-preference-list =
          "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        cert-digest-algo = "SHA512";
        s2k-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";
        charset = "utf-8";
        fixed-list-mode = true;
        no-comments = true;
        no-emit-version = true;
        no-greeting = true;
        keyid-format = "0xlong";
        list-options = "show-uid-validity";
        verify-options = "show-uid-validity";
        with-fingerprint = true;
        require-cross-certification = true;
        no-symkey-cache = true;
        use-agent = true;
        throw-keyids = true;
      };
    };
    services.gpg-agent = {
      enable = true;
      enableExtraSocket = true;
      enableScDaemon = false;
      enableSshSupport = true;
      pinentryFlavor = "gtk2";
      verbose = true;
    };
    #fzf
    xdg.configFile."fzf".source = ../config/.config/fzf;
    xdg.configFile."nixpkgs/config.nix".source = ../../nix/config.nix;
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = pkgs.starship;
    };

    xdg.dataFile."zsh/nyx_zshrc".text = ''
        "source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"}
        "source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"}
      '';

    xdg.configFile."starship".source = ../config/.config/starship;
    xdg.configFile."shell".source = ../config/.config/shell;
    home.file.".bash_profile".source = ../config/.bash_profile;
    home.file.".bashrc".source = ../config/.bashrc;
    home.file.".inputrc".source = ../config/.inputrc;
    home.file.".profile".source = ../config/.profile;
    home.file.".zshenv".source = ../config/.zshenv;
    home.file.".config/zsh".source = ../config/.config/zsh;
    home.file.".config/nvim".source = ../config/.config/nvim;
    xdg.dataFile = with pkgs.tree-sitter-grammars; 
    let
      grammars = with pkgs.tree-sitter-grammars; [
        tree-sitter-bash
        tree-sitter-c
        tree-sitter-c-sharp
        tree-sitter-comment
        tree-sitter-cpp
        tree-sitter-css
        tree-sitter-go
        tree-sitter-javascript
        tree-sitter-json
        tree-sitter-lua
        tree-sitter-make
        tree-sitter-nix
        tree-sitter-regex
        tree-sitter-rust
        tree-sitter-toml
        tree-sitter-tsx
        tree-sitter-typescript
        tree-sitter-vim
        tree-sitter-yaml
      ];
      parseName = x: removeSuffix "-grammar" (removePrefix "tree-sitter-" (getName x));
      # parsers = listToAttrs (map
      #   (p: {
      #     name = "nvim/parser/${parseName p}.so";
      #     value = { source = "${p}/parser"; };
      #   })
      #   grammars);
      parsers = { };
      in parsers // {
      "nvim/lib/libsqlite3.so".source = "${pkgs.sqlite.out}/lib/libsqlite3.so";
    };
/*
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
  */
}
