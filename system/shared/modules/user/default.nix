{ config, self, system, userConf, ... }:

with self.lib;
let
  cfg = config.nyx.modules.user;
  #defaultName = existsOrDefault "name" user null;
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
    (mkIf (cfg.home != null) {
      home-manager.users."${userConf.userName}" = mkUserHome { inherit system userConf; config = cfg.home; };
    })
    {
      # Enable zsh in order to add /run/current-system/sw/bin to $PATH
      programs.zsh.enable = true;
    }
  ];
}

