{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.shell.nixvim;

  # Prebuilt grammars (no :TSInstall at runtime)
  treeSitterGrammars = with pkgs.tree-sitter-grammars; [
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
    tree-sitter-markdown
    tree-sitter-nix
    tree-sitter-regex
    tree-sitter-rust
    tree-sitter-toml
    tree-sitter-tsx
    tree-sitter-typescript
    tree-sitter-vim
    tree-sitter-yaml
  ];
in
{
  # Define the option your cfg references
  options.nyx.modules.shell.nixvim = {
    enable = mkEnableOption "Enable nixvim with telescope, lualine, neo-tree, and prebuilt treesitter grammars";
  };

  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = true;

      # basic editor feel
      opts = {
        number = true;
        relativenumber = true;
        clipboard = "unnamedplus";
      };
      globals.mapleader = " ";
      # icons
      plugins.web-devicons.enable = true;
      # ===== Treesitter: use Nix-built parsers (no writes to /nix/store)
      plugins.treesitter = {
        enable = true;
        nixGrammars = true;
        grammarPackages = treeSitterGrammars;
        settings = {
          highlight = { enable = true; };
          incremental_selection = { enable = true; };
          indent = { enable = true; };
          auto_install = false;
        };
      };

      # ===== Telescope (with fzf-native)
      plugins.telescope = {
        enable = true;
        settings = {
          defaults = {
            sorting_strategy = "ascending";
            layout_config = { prompt_position = "top"; };
          };
        };
        extensions = {
          "fzf-native".enable = true; # fast sorter
        };
      };

      # ===== Statusline (lualine)
      plugins.lualine = {
        enable = true;
        settings = {
          options = {
            theme = "auto";
            globalstatus = true;
            disabled_filetypes = { statusline = [ "neo-tree" ]; };
          };
          sections = {
            lualine_a = [ "mode" ];
            lualine_b = [ "branch" ];
            lualine_c = [
              { __unkeyed_1 = "filetype"; icon_only = true; separator = ""; padding = { left = 1; right = 0; }; }
              { __unkeyed_1 = "filename"; path = 1; symbols = { modified = "  "; readonly = ""; unnamed = ""; }; }
              "diagnostics"
            ];
            lualine_x = [ "encoding" "fileformat" "filetype" ];
            lualine_y = [ "progress" ];
            lualine_z = [ "location" ];
          };
          extensions = [ "neo-tree" "fzf" ];
        };
      };

      # ===== Tree view (neo-tree) + hard deps on RTP for neo-tree/telescope/devicons
      extraPlugins = with pkgs.vimPlugins; [
        neo-tree-nvim
        nui-nvim
        plenary-nvim
        nvim-web-devicons
        telescope-fzf-native-nvim
        image-nvim
      ];

      # ===== Tools Telescope uses under the hood (+ TS toolchain/parsers)
      extraPackages = with pkgs; [
        ripgrep      # live_grep
        fd           # file finder
        tree-sitter
        wl-clipboard # system clipboard on Wayland
        imagemagick
      ] ++ lib.optionals pkgs.stdenv.isLinux [
        ueberzugpp   # image.nvim ueberzug backend
      ] ++ treeSitterGrammars;

      # ===== Keymaps: tree + telescope
      keymaps = [
        # Neo-tree
        {
          mode = "n"; key = "<leader>e";
          action = "<cmd>Neotree toggle reveal<cr>";
          options.desc = "Toggle file tree (neo-tree)";
        }

        # Telescope
        { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<cr>"; options.desc = "Find files"; }
        { mode = "n"; key = "<leader>fg"; action = "<cmd>Telescope live_grep<cr>";  options.desc = "Live grep"; }
        { mode = "n"; key = "<leader>fb"; action = "<cmd>Telescope buffers<cr>";    options.desc = "Buffers"; }
        { mode = "n"; key = "<leader>fh"; action = "<cmd>Telescope help_tags<cr>";  options.desc = "Help tags"; }
      ];

      # ===== Minimal, stable neo-tree setup
      extraConfigLua = ''
        -- Register missing #is-not? predicate so newer treesitter grammars
        -- don't error on neovim 0.11.x (which lacks a built-in handler).
        vim.treesitter.query.add_predicate("is-not?", function() return true end, { force = true })

        -- Force transparent backgrounds so the terminal opacity shows through.
        local function make_transparent()
          local groups = {
            "Normal", "NormalNC", "NormalFloat",
            "SignColumn", "EndOfBuffer",
            "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer",
            "NeoTreeWinSeparator",
          }
          for _, g in ipairs(groups) do
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = g })
            if ok then
              hl.bg = nil
              hl.ctermbg = nil
              vim.api.nvim_set_hl(0, g, hl)
            else
              vim.api.nvim_set_hl(0, g, { bg = "NONE" })
            end
          end
        end
        make_transparent()
        vim.api.nvim_create_autocmd("ColorScheme", { callback = make_transparent })

        vim.g.neo_tree_remove_legacy_commands = 1

        require("neo-tree").setup({
          filesystem = {
            filtered_items = {
              visible = true,
              hide_dotfiles = false,
              hide_gitignored = true,
            },
            follow_current_file = { enable = true },
            bind_to_cwd = false,
          },
          window = {
            mappings = {
              ["h"] = "close_node",
              ["l"] = "open",
              ["<cr>"] = "open",
            },
          },
          default_component_configs = {
            indent = {
              with_expanders = true,
              expander_collapsed = "",
              expander_expanded  = "",
            },
          },
        })
      '' + lib.optionalString pkgs.stdenv.isLinux ''
        -- image.nvim: inline image rendering via kitty protocol (Linux only)
        local _ok, image = pcall(require, "image")
        if _ok then
          image.setup({
            backend = "kitty",
            integrations = {
              markdown = {
                enabled = true,
                clear_in_insert_mode = false,
                download_remote_images = true,
              },
            },
            max_width = nil,
            max_height = nil,
            max_height_window_percentage = 80,
            max_width_window_percentage = 80,
            window_overlap_clear_enabled = false,
          })
        end
      '';
    };
  };
}
