{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.obs;
in
{
  options.nyx.modules.app.obs = {
    enable = mkEnableOption "Open Broadcast Software";
    package = mkOption {
      description = "Package for obs-studio";
      type = with types; nullOr package;
      default = pkgs.obs-studio;
    };
  };

  config = mkIf cfg.enable {
    programs.obs-studio = mkIf (cfg.package != null) {
      enable = true;
      package = cfg.package;
    };
  };
}
