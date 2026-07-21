{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let cfg = config.nyx.modules.system.vial;
in
{
  options.nyx.modules.system.vial = { 
    enable = mkEnableOption "vial"; 
  };
  config = mkIf cfg.enable {
    # GROUP=plugdev matches how vial-upstream ships the rule and stays consistent
    # with the Arch installer at setup/arch/02-install-packages.sh. On NixOS,
    # services.udev.extraRules gets installed at priority 99- which is fine here:
    # the `uaccess` builtin runs both from 73-seat-late.rules AND (redundantly) via
    # logind on session activation, so ordering isn't as fragile as with a
    # hand-installed /etc/udev/rules.d/99-* file on Arch. The tag + group combo
    # gives us belt-and-suspenders access.
    services.udev.extraRules = ''
      # Vial user access to /dev/hidraw
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl"
    '';

    # Ensure the group exists on NixOS hosts that don't already declare it.
    users.groups.plugdev = { };
  };
}