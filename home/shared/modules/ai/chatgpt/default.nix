{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.ai.chatgpt;
in
{
  options.nyx.modules.ai.chatgpt = {
    enable = mkEnableOption "Chat GPT";

    codexPackage = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "The openai-codex package. Set to null to manage via system package manager (e.g. pacman on Arch). Not currently in nixpkgs.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [ chatgpt-cli ]
      ++ optional (cfg.codexPackage != null) cfg.codexPackage;
  };
}

