{ config, pkgs, ... }:

{
  home = {
    sessionVariables = {
      # --- Standard Defaults ---
      EDITOR = "nvim";
      BROWSER = "google-chrome-stable";
      TERMINAL = "kitty";
   
      CLUTTER_BACKEND = "wayland";
      
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      QT_QPA_PLATFORMTHEME = "qt5ct"; 

      HYPRCURSOR_THEME = "MyCursor";
      HYPRCURSOR_SIZE = "24";
      XCURSOR_THEME = "MyCursor"; # Should match the Hyprcursor theme name usually
      XCURSOR_SIZE = "24";
    };
  };
}