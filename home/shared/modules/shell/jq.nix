{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.jq;
in
{
  options.nyx.modules.shell.jq = {
    enable = mkEnableOption "jq configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        jq
      ];
  };
}
