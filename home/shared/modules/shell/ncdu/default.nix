{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.ncdu;
in
{
  options.nyx.modules.shell.ncdu = {
    enable = mkEnableOption "ncdu interactive disk usage navigator";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.ncdu ];
    nyx.modules.shell.zsh.initExtra =
      mkIf config.nyx.modules.shell.zsh.enable ''
        alias du="ncdu"
      '';
  };
}
