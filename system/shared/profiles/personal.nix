{ config, inputs, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.profiles.personal;
in
{
  options.nyx.profiles.personal = {
    enable = mkEnableOption "work profile";
  };
  
  config = mkIf cfg.enable {
    environment.systemPackages = [
        pkgs.angband
    ];
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
