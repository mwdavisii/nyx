{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.audio-recording;
in
{
  options.nyx.modules.app.audio-recording = {
    enable = mkEnableOption "PipeWire audio recording tools (pw-record and Helvum patchbay)";

    pwRecordPackage = mkOption {
      description = "Package providing pw-record";
      type = with types; nullOr package;
      default = pkgs.pipewire;
    };

    helvumPackage = mkOption {
      description = "Package for Helvum PipeWire patchbay";
      type = with types; nullOr package;
      default = pkgs.helvum;
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      optional (cfg.pwRecordPackage != null) cfg.pwRecordPackage
      ++ optional (cfg.helvumPackage != null) cfg.helvumPackage;
  };
}
