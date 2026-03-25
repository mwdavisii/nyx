{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.ytmPlayer;
in
{
  options.nyx.modules.shell.ytmPlayer = {
    enable = mkEnableOption "ytm-player YouTube Music TUI (OAuth, playlist support)";
    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.ytm-player;
      description = "ytm-player package. Defaults to ytm-player (base). Use pkgs.ytm-player-full for mpris/discord/lastfm/spotify extras once upstream fixes spotifyscraper build.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = optional (cfg.package != null) cfg.package;
  };
}
