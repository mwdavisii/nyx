{ config, inputs, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.profiles.macbook;
in
{
  options.nyx.profiles.macbook = {
    enable = mkEnableOption "macbook profile";
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
        nerdfonts
        twemoji-color-font
        fira-code
        fira-code-symbols
      ];
    };
  };
}
