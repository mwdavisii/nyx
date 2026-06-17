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
      description = "The claude-code package. Set to null to manage via AUR or system package manager.";
    };

    bunPackage = mkOption {
      type = types.nullOr types.package;
      default = pkgs.bun;
      description = "Bun runtime for ccstatusline. Set to null if managing bun via system package manager.";
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      optional (cfg.package != null) cfg.package
      ++ optional (cfg.bunPackage != null) cfg.bunPackage
      ++ [ pkgs.jq ];

  };
}
