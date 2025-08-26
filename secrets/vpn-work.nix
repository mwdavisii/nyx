{ config, lib, pkgs, userConf, agenix, secrets, ... }:
with lib;
let
  cfg = config.nyx.secrets.workvpn;
  homePath = if pkgs.stdenv.isDarwin then "/Users/${userConf.userName}" else "/home/${userConf.userName}";
in
{
  options.nyx.secrets.workvpn = {
    enable = mkEnableOption "Enable Work VPN Configurations";
  };

  config = mkIf cfg.enable {
    age.secrets.workvpn = {
      symlink = true;
      file = "${secrets}/encrypted/workvpn.age";
      mode = "400";
      path = "${homePath}/.openvpn3/workvpn";
      owner = "${userConf.userName}";
    };
  };
}

