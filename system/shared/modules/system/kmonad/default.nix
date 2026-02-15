{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let cfg = config.nyx.modules.system.kmonad;
in
{
  options.nyx.modules.system.kmonad = { 
    enable = mkEnableOption "kmonad"; 
  };
  config = mkIf cfg.enable {
    services.udev.extraRules =
      ''
        # KMonad user access to /dev/uinput
        KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
      '';
    environment.systemPackages = with pkgs; [
      kmonad
    ];
  };
}