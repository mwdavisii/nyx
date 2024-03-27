{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.nyx.modules.theme;
in
{
  imports = [
    ./cava
  ];
  options.nyx.modules.theme = {
    name = mkOption {
      type = types.str;
      description = "Name of the theme loaded into color attributes";
      default = "nightfox";
    };
    colors = mkOption {
      type = types.attrs;
      description = "Color attributes";
      internal = true;
    };
  };

  config = {
    nyx.modules.theme.colors = with builtins; fromJSON (readFile ((toString ./.) + "/${cfg.name}.json"));

    gtk = {
      enable = true;
      iconTheme = {
        name = "Yaru-magenta-dark";
        package = pkgs.yaru-theme;
      };

      theme = {
        name = "Tokyonight-Dark-B-LB";
        package = pkgs.tokyo-night-gtk;
      };

      cursorTheme = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
      };
    };

  };
}

# Default mouse acceleration
# defaults read .GlobalPreferences com.apple.mouse.scaling
# Result: 0.875
#
# Disable mouse acceleration
# defaults write .GlobalPreferences com.apple.mouse.scaling 0
