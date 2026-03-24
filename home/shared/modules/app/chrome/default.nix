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
        "text/html" = "google-chrome.desktop";
        "x-scheme-handler/http" = "google-chrome.desktop";
        "x-scheme-handler/https" = "google-chrome.desktop";
        "x-scheme-handler/about" = "google-chrome.desktop";
        "x-scheme-handler/unknown" = "google-chrome.desktop";
      };
    };
  };
}