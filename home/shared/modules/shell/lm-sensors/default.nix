{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.lmSensors;
in
{
  options.nyx.modules.shell.lmSensors = {
    enable = mkEnableOption "lm-sensors hardware monitoring CLI (Linux only)";
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    home.packages = [ pkgs.lm_sensors ];
  };
}
