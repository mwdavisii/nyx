{ config, lib, pkgs, modulesPath, hostName, inputs, ... }:
with lib;
let 
  cfg = config.nyx.modules.system.kmonad;
in
{
  options.nyx.modules.system.kmonad = {
    enable = mkEnableOption "kmonad Settings";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      inputs.kmonad
    ];

  services.kmonad = {
      enable = true;
      package = import ../../../../nix/pkgs/kmonad/ { inherit pkgs; };
      keyboards = {
        laptop-internal = {
          defcfg = {
            enable = true;
            fallthrough = true;
            compose.key = null;
          };

          device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
          config = builtins.readFile /home/nateeag/nixos-framework-setup/kmonad.kbd;
        };
      };
    };

  };
}