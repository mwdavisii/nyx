{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.shell.homelabTools;

  dns-add = pkgs.writeShellScriptBin "dns-add"
    (builtins.readFile ./scripts/dns-add.sh);

  dns-delete = pkgs.writeShellScriptBin "dns-delete"
    (builtins.readFile ./scripts/dns-delete.sh);

  dhcp-reserve = pkgs.writeShellScriptBin "dhcp-reserve"
    (builtins.readFile ./scripts/dhcp-reserve.sh);

  dhcp-list = pkgs.writeShellScriptBin "dhcp-list"
    (builtins.readFile ./scripts/dhcp-list.sh);

  dhcp-delete = pkgs.writeShellScriptBin "dhcp-delete"
    (builtins.readFile ./scripts/dhcp-delete.sh);
in
{
  options.nyx.modules.shell.homelabTools = {
    enable = mkEnableOption "Homelab DNS (BIND/nsupdate) and DHCP (Kea) management tools";
  };

  config = mkIf cfg.enable {
    home.packages = [
      dns-add
      dns-delete
      dhcp-reserve
      dhcp-list
      dhcp-delete
      pkgs.jq        # used by dhcp scripts over SSH
      pkgs.openssh   # ssh for dhcp scripts
    ];
  };
}
