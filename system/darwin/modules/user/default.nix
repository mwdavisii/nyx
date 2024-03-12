{ config, pkgs, self, userConf, ... }:

with self.lib;
let
  cfg = config.nyx.modules.user;
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
