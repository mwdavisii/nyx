{ config, lib, ... }:

with lib;
let
  cfg = config.nyx.modules.ai.launcher;
in
{
  options.nyx.modules.ai.launcher = {
    enable = mkEnableOption "AI launcher script (wraps Claude, Codex, Gemini)";
  };

  config = mkIf cfg.enable {
    home.file.".local/bin/ai" = {
      source = ./scripts/ai;
      executable = true;
    };
  };
}
