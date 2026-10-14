{ config, lib, ... }:

with lib;
{
  config = {
    home.sessionVariables = {
      # Ensure Flatpak export shares (user and system) are visible to desktop
      # launchers, MIME associations, and icon/theme lookups.
      XDG_DATA_DIRS = "$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share";
    };
  };
}
