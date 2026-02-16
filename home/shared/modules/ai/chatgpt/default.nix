{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.ai.chatgpt;
in
{
  options.nyx.modules.ai.chatgpt = {
    enable = mkEnableOption "Chat GPT";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
        chatgpt-cli
    ];
  };
}

