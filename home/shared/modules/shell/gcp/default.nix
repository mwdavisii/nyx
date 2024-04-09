{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.gcp;
in
{
  options.nyx.modules.shell.gcp = {
    enable = mkEnableOption "GCP SDK configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        google-cloud-sdk
      ];
  };
}
