{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.ai.codex;
in
{
  options.nyx.modules.ai.codex = {
    enable = mkEnableOption "OpenAI Codex CLI (lightweight terminal coding agent)";

    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.codex;
      description = "The codex package. Set to null to manage via system package manager (e.g. snap or npm on hosts where nixpkgs' codex isn't available).";
    };
  };

  config = mkIf cfg.enable {
    home.packages = optional (cfg.package != null) cfg.package;
  };
}
