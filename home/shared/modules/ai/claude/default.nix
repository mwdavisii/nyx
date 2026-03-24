{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.ai.claude;
in
{
  options.nyx.modules.ai.claude = {
    enable = mkEnableOption "Claude Code";
    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.claude-code;
      description = "The claude-code package to install. Set to null to manage via AUR or system package manager.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkIf (cfg.package != null) [ cfg.package ];
  };
}

