{ config, lib, pkgs, self, user, userConf, system, ... }:

with self.lib;
let
  cfg = config.nyx.modules.user;

  isPasswdCompatible = str: !(hasInfix ":" str || hasInfix "\n" str);
  passwdEntry = type: lib.types.addCheck type isPasswdCompatible // {
    name = "passwdEntry ${type.name}";
    description = "${type.description}, not containing newlines or colons";
  };

  defaultHashedPassword = existsOrDefault "hashedPassword" user null;

  defaultExtraGroups = [
    "audio"
    "docker"
    "games"
    "locate"
    "libvirtd"
    "networmanager"
    "wheel"
    "video"
    "netdev"
  ];
in
{
  options.nyx.modules.user = {
    extraGroups = mkOption {
      type = types.listOf types.str;
      default = defaultExtraGroups;
      description = "The user's auxiliary groups.";
    };
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
    hashedPassword = mkOption {
      type = with types; nullOr (passwdEntry str);
      default = defaultHashedPassword;
      description = ''
        Specifies the hashed password for the user.
      '';
    };
  };

  config = mkMerge [
    {
      home-manager.users."${userConf.userName}" = mkUserHome { inherit system userConf; config = cfg.home; };
      # Enable zsh in order to add /run/current-system/sw/bin to $PATH
      programs.zsh.enable = true;
      users = {
        users."${cfg.name}" = with cfg; {
          inherit hashedPassword extraGroups;
          isNormalUser = true;
          name = "${userConf.userName}";
          home = "/home/${userConf.userName}";
          shell = pkgs.zsh;
          uid = 1000;
        };

        # Do not allow users to be added or modified except through Nix configuration.
        mutableUsers = false;
      };
      nix.settings.trusted-users = [ "${cfg.name}" ];
    }
  ];
}
