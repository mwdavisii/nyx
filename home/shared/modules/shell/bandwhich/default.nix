{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.bandwhich;
in
{
  options.nyx.modules.shell.bandwhich = {
    enable = mkEnableOption "bandwhich network bandwidth monitor by process (Linux only)";
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    home.packages = [ pkgs.bandwhich ];
  };
}
