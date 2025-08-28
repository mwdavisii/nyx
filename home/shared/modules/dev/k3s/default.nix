{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.dev.k3s;
in
{
  options.nyx.modules.dev.k3s = {
        enable = mkEnableOption "K3s Installation";
    };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        k3s
      ];
    };
  };
}

