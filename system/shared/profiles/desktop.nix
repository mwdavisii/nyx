{ config, inputs, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.profiles.desktop;
in
{
  options.nyx.profiles.desktop = {
    enable = mkEnableOption "desktop profile";
  };
  
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      twemoji-color-font
    ];
    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        twemoji-color-font
        fira-code
        fira-code-symbols
      ];
    };
  };
}
