{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.atuin;
in
{
  options.nyx.modules.shell.atuin = {
    enable = mkEnableOption "atuin shell history with SQLite backend (replaces mcfly)";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.atuin ];

    nyx.modules.shell.bash.initExtra =
      mkIf config.nyx.modules.shell.bash.enable ''
        eval "$(atuin init bash)"
      '';

    nyx.modules.shell.zsh.initExtra =
      mkIf config.nyx.modules.shell.zsh.enable ''
        eval "$(atuin init zsh)"
      '';
  };
}
