{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.etcd;
in
{
  options.nyx.modules.shell.etcd = {
    enable = mkEnableOption "etcd configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        etcd
      ];
  };
}