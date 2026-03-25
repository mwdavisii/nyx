{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.ytmPlayer;
in
{
  options.nyx.modules.shell.ytmPlayer = {
    enable = mkEnableOption "ytm-player YouTube Music TUI (OAuth, playlist support)";
    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.ytm-player-full;
      description = "ytm-player package. Defaults to ytm-player-full (includes mpris, discord, lastfm, spotify). Set null to manage externally.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = optional (cfg.package != null) cfg.package;
  };
}
