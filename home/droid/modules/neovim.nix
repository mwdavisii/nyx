{ config, lib, pkgs, ... }:
with pkgs;
let 
    lspServers = [
        marksman
        nodePackages.bash-language-server
        nodePackages.pyright
        nodePackages.typescript-language-server
        nodePackages.vim-language-server
        nodePackages.write-good
        #rnix-lsp
    ];
    
    debugAdaptors = [
      lldb
    ];

    formatters = [
      stylua
      shfmt
      nixpkgs-fmt
      prettierd
      proselint
      nodePackages.eslint_d
      nodePackages.yaml-language-server
    ];
in
{
  xdg.configFile."nvim".source = ../../config/.config/nvim;
  home.packages = with pkgs;
    let
      package = neovim;
    in
    [ package xclip ] ++ lspServers ++ debugAdaptors ++ formatters;

    # Add Treesitter parsers
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
        # Currently this does not point to the correct markdown parser
        # Correct one is: https://github.com/MDeiml/tree-sitter-markdown
        # tree-sitter-markdown
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
    in
    parsers // {
      "nvim/lib/libsqlite3.so".source = "${pkgs.sqlite.out}/lib/libsqlite3.so";
    };
}
