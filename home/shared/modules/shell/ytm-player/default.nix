{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.ytmPlayer;
in
{
  options.nyx.modules.shell.ytmPlayer = {
    enable = mkEnableOption "ytm-player YouTube Music TUI (OAuth, playlist support)";
    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "ytm-player package. Defaults to null — install via AUR (Arch) or pip.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = optional (cfg.package != null) cfg.package;
  };
}
