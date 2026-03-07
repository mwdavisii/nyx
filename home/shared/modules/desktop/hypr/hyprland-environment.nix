{ config, pkgs, ... }:

{
  home = {
    sessionVariables = {
      # --- Standard Defaults ---
      EDITOR = "nvim";
      BROWSER = "google-chrome-stable";
      TERMINAL = "kitty";

      # --- Gaming / Controller ---
      # xpadneo blocks hidraw (MODE:="0000") to prevent driver conflicts. SDL3's HIDAPI claims
      # Xbox controllers by PID, tries hidraw, fails silently, and never falls back to evdev.
      # Disabling HIDAPI for Xbox forces SDL to use xpadneo's evdev interface instead.
      # SDL_GAMECONTROLLERCONFIG provides the GUID→button mapping for xpadneo's spoofed PID/version
      # (0x0B22→0x028E, version 0x0522→0x1130), since Steam no longer injects this after 1.0.0.85-5.
      SDL_JOYSTICK_HIDAPI_XBOX_ONE = "0";
      SDL_JOYSTICK_HIDAPI_XBOX = "0";
      SDL_GAMECONTROLLERCONFIG = "050000005e0400008e02000030110000,Xbox Wireless Controller,a:b0,b:b1,x:b2,y:b3,back:b6,guide:b8,start:b7,leftstick:b9,rightstick:b10,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a3,righty:a4,lefttrigger:a2,righttrigger:a5,platform:Linux,";

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
