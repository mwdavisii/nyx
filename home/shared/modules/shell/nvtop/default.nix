{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.nvtop;
in
{
  options.nyx.modules.shell.nvtop = {
    enable = mkEnableOption "nvtop GPU monitor (Linux only)";
    package = mkOption {
      type = with types; nullOr package;
      default = pkgs.nvtopPackages.full;
      description = "nvtop package variant to use (e.g. nvtopPackages.amd, nvtopPackages.nvidia). Set to null to manage via system package manager.";
    };
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux && cfg.package != null) {
    home.packages = [ cfg.package ];
  };
}
