{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let
  cfg = config.nyx.modules.system.ssh;
in
{
  options.nyx.modules.system.ssh = {
    enable = mkEnableOption "SSH Settings";
  };

  config = mkIf cfg.enable {
    services.openssh.enable = true;
    services.openssh.passwordAuthentication = true;
  };
}
