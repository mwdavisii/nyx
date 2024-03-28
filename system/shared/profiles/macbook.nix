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
    fonts = {
      fonts = with pkgs; [
        (
          nerdfonts.override {
            fonts = [ "JetBrainsMono" "Hack" "Meslo" "UbuntuMono" ];
          }
        )
      ];
    };
  };
}