{ config, lib, pkgs, modulesPath, hostName, userConf, ... }:
with lib;
let cfg = config.nyx.modules.system.k3s;
in
{
  options.nyx.modules.system.k3s = {
    enable = mkEnableOption "K3s Install Settings";
  };

  config = mkIf cfg.enable {
    services.k3s = {
      enable = true;
      role = "server"; # This sets it up as a server/master node
      
      # This is important for installing Istio later, as it prevents conflicts.
      extraFlags = "--disable=traefik"; 
    };
};
}
