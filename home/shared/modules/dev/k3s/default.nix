{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.dev.k3s;
in
{

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        k3s
      ];
        };
  };
}

