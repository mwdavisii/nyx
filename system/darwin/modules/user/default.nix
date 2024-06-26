{ config, pkgs, self, userConf, system, ... }:

with self.lib;
let
  cfg = config.nyx.modules.user;
in
{
  options.nyx.modules.user = {
    name = mkOption {
      type = types.str;
      default = userConf.userName;
      description = "User's name";
    };
    home = mkOption {
      type = with types; nullOr types.path;
      default = null;
      description = "Path of home manager home file";
    };
   };

  config = mkMerge [
    {
      home-manager.users."${userConf.userName}" = mkUserHome { inherit system userConf; config = cfg.home; };
      users.users.${userConf.userName} = {
        name = "${userConf.userName}";
        home = "/Users/${userConf.userName}";
        isHidden = false;
        shell = pkgs.zsh;
    };
    }
  ];
}
