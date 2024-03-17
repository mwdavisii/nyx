{ config, pkgs, self, userConf, secrets, ... }:

with self.lib;
let
  cfg = config.nyx.modules.user;
  homePath = if pkgs.stdenv.isDarwin then "/Users/${userConf.userName}" else "/home/${userConf.userName}";
in
{
  options.nyx.modules.user = { };

  config = mkMerge [
    {
      users.users.${userConf.userName} = {
        name = "${userConf.userName}";
        home = if pkgs.stdenv.isDarwin then "/Users/${userConf.userName}" else "/home/${userConf.userName}";
        isHidden = false;
        shell = pkgs.zsh;
    };
    }
  ];
}
