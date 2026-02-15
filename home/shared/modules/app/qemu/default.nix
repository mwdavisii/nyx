{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.qemu;
in
{
  options.nyx.modules.app.qemu = {
    enable = mkEnableOption "Qemu";
  };

  config = mkIf cfg.enable {
    # go ahead and install adb here since it's required
    home.packages = with pkgs; [
        qemu
    ];
  };
}



