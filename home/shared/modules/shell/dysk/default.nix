{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.dysk;
in
{
  options.nyx.modules.shell.dysk = {
    enable = mkEnableOption "dysk modern df replacement";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.dysk ];
    nyx.modules.shell.zsh.initExtra =
      mkIf config.nyx.modules.shell.zsh.enable ''
        alias df="dysk"
      '';
  };
}
