{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.app.kitty;
in
{
  options.nyx.modules.app.kitty = {
    enable = mkEnableOption "kitty configuration";
    package = mkOption {
      description = "Package for wezterm";
      type = with types; nullOr package;
      default = pkgs.kitty;
    };
    fontSize = mkOption {
      description = "Override font size";
      type = with types; nullOr int;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      package = cfg.package;
      settings = {
        confirm_os_window_close = 0;
        cursor_shape = "block";
        shell_integration = "no-rc enabled";
        detect_urls = "yes";
        enable_audio_bell = "no";
        tab_bar_min_tabs = 1;
        tab_bar_edge = "top";
        tab_bar_style = "powerline";
        font_family = "Hack Nerd Font Mono";
        remember_window_size = "yes";
      } // lib.optionalAttrs (cfg.fontSize != null) {
        font_size = cfg.fontSize;
      } // lib.optionalAttrs (cfg.fontSize == null) {
        font_size = 11;
      };
      keybindings = {
        "ctrl+c" = "copy_or_interrupt";
      };
      extraConfig = ''
        include ~/.cache/wal/colors-kitty.conf
      '';
    };
  };
}


