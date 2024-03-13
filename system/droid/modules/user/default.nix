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
        home = "/data/data/com.termux.nix/files/home/nyx";
        shell = pkgs.zsh;
    };
    }
  ];
}
