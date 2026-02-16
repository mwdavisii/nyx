{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.ai.gemini;
in
{
  options.nyx.modules.ai.gemini = {
    enable = mkEnableOption "Gemini CLI";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
        gemini-cli
    ];
  };
}

