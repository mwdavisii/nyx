{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.yq;
in
{
  options.nyx.modules.shell.yq = {
    enable = mkEnableOption "jq configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        yq
      ];
  };
}
