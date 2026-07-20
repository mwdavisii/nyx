{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.app.chromium;
in
{
  options.nyx.modules.app.chromium = {
    enable = mkEnableOption "Chromium app";
    package = mkOption {
      description = ''
        Package for Chromium. Set to `null` on hosts where Chromium is
        installed outside Nix (e.g. Arch via `pacman -S chromium`), because
        Nix's Chromium build expects NixOS's /run/opengl-driver mechanism and
        cannot find EGL/DRM userspace on non-NixOS systems (GPU accel breaks).
      '';
      type = with types; nullOr package;
      default = pkgs.chromium;
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [ cfg.package ];
  };
}
