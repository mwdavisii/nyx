{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.chrome;
  chromePath = "${pkgs.google-chrome}/bin/google-chrome-stable";
  defaultPath = "${pkgs.qutebrowser}/bin/qutebrowser";
in
{
  options.nyx.modules.app.chrome = {
    enable = mkEnableOption "Google Chrome";
    makeDefaultBrowser = mkOption{
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      google-chrome
    ];

   #home.sessionVariables = {
   #   environment.sessionVariables.DEFAULT_BROWSER = if cfg.makeDefaultBrowser then "${chromePath}" else "${defaultPath}";
   # };

    xdg.mimeApps = {
      enable = cfg.makeDefaultBrowser;
      defaultApplications = {
        "text/html" = "${pkgs.google-chrome}/bin/google-chrome-stable";
        "x-scheme-handler/http" = "${pkgs.google-chrome}/bin/google-chrome-stable";
        "x-scheme-handler/https" = "${pkgs.google-chrome}/bin/google-chrome-stable";
        "x-scheme-handler/about" = "${pkgs.google-chrome}/bin/google-chrome-stable";
        "x-scheme-handler/unknown" = "${pkgs.google-chrome}/bin/google-chrome-stable";
      };
    };
  };
}