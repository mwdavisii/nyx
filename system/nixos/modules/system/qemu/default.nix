{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let cfg = config.nyx.modules.system.qemu;
in
{
  options.nyx.modules.system.qemu = {
    enable = mkEnableOption "qemu Settings";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      qemu
      libvirt
    ];
    
  };
}
