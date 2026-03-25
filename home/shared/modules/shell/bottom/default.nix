{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.bottom;
in
{
  options.nyx.modules.shell.bottom = {
    enable = mkEnableOption "bottom (btm) Rust system monitor";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.bottom ];
  };
}
