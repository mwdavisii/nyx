{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.lazygit;
in
{
  options.nyx.modules.shell.lazygit = {
    enable = mkEnableOption "lazygit TUI git client";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.lazygit ];
  };
}
