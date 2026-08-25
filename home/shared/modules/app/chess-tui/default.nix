{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.chess-tui;
in
{
  options.nyx.modules.app.chess-tui = {
    enable = mkEnableOption "chess-tui (terminal chess with lichess backend)";

    withStockfish = mkOption {
      type = types.bool;
      default = true;
      description = "Install stockfish and set it as the default UCI engine.";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression ''
        {
          display_mode = "ASCII";
          bot_difficulty = 1;
        }
      '';
      description = ''
        Extra settings merged into ~/.config/chess-tui/config.toml.
        The lichess token is NOT set here — run chess-tui once and enter it
        interactively, or use `chess-tui -l <token>`; the app persists it
        into the config file itself.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ chess-tui ]
      ++ optional cfg.withStockfish stockfish;

    xdg.configFile."chess-tui/config.toml".source =
      (pkgs.formats.toml { }).generate "chess-tui-config.toml"
        ({
          display_mode = "DEFAULT";
          log_level = "OFF";
          bot_depth = 10;
          # Off by default: Nix's alsa-lib can't reliably find the host's
          # system PCM plugins, and chess-tui logs an ALSA error per keystroke
          # when the audio device fails. Enable per-host via
          # nyx.modules.app.chess-tui.settings.sound_enabled = true.
          sound_enabled = false;
          animations_enabled = false;
        }
        // optionalAttrs cfg.withStockfish {
          engine_path = "${pkgs.stockfish}/bin/stockfish";
        }
        // cfg.settings);
  };
}
