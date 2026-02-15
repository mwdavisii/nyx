{ config, pkgs, ... }:

{
  home = {
    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "google-chrome-stable";
      TERMINAL = "kitty";
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_RENDERER_ALLOW_SOFTWARE = "1";
      CLUTTER_BACKEND = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      HYPRCURSOR_THEME = "MyCursor";
      HYPRCURSOR_SIZE = 24;
      XCURSOR_THEME = "default";
      XCURSOR_SIZE = 24;
      QT_STYLE_OVERRIDE = "adwaita-dark";
    };
  };
}
