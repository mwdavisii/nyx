{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.app.jupyter;
in
{
  options.nyx.modules.app.jupyter = { enable = mkEnableOption "jupyter app"; };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        jupyter
      ];
  };
}

