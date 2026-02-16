{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.ai.claude;
in
{
  options.nyx.modules.ai.claude = {
    enable = mkEnableOption "Claude Code";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
        claude-code
    ];
  };
}

