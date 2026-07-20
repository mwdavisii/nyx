{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.chrome;
in
{
  options.nyx.modules.app.chrome = {
    enable = mkEnableOption "Google Chrome";
    package = mkOption {
      description = ''
        Package for Google Chrome. Set to `null` on hosts where Chrome is
        installed outside Nix (e.g. Arch via `yay -S google-chrome`), because
        Nix's Chrome build expects NixOS's /run/opengl-driver mechanism and
        cannot find EGL/DRM userspace on non-NixOS systems (GPU accel breaks).
      '';
      type = with types; nullOr package;
      default = pkgs.google-chrome;
    };
    makeDefaultBrowser = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [ cfg.package ];

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
