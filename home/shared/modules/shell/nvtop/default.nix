{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.nvtop;
in
{
  options.nyx.modules.shell.nvtop = {
    enable = mkEnableOption "nvtop GPU monitor (Linux only)";
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    home.packages = [ pkgs.nvtopPackages.full ];
  };
}
