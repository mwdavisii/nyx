{ config, lib, ... }:

with lib;
let
  cfg = config.nyx.modules.ai.ollama;
in
{
  options.nyx.modules.ai.ollama = {
    enable = mkEnableOption "Ollama local LLM inference";
  };

  config = mkIf cfg.enable {
    systemd.user.services.ollama = {
      Unit = {
        Description = "Ollama local LLM server";
        After = [ "default.target" ];
      };
      Service = {
        ExecStart = "/usr/bin/ollama serve";
        Environment = [ "OLLAMA_HOST=127.0.0.1:11434" ];
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
