{ config, lib, pkgs, user, ... }:

with lib;
let
  cfg = config.nyx.modules.shell.git;

  signModule = types.submodule {
    options = {
      key = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The default GPG signing key fingerprint.";
      };

      signByDefault = mkOption {
        type = types.bool;
        default = false;
        description = "Whether commits should be signed by default.";
      };

      gpgPath = mkOption {
        type = types.nullOr types.str;
        default = "${pkgs.gnupg}/bin/gpg2";
        defaultText = "\${pkgs.gnupg}/bin/gpg2";
        description = "Path to GnuPG binary to use.";
      };
    };
  };
in
{
  options.nyx.modules.shell.git = {
    enable = mkEnableOption "git configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      git
      gitAndTools.git-crypt
      gitAndTools.delta
      gitAndTools.gh
      gitAndTools.glab
      gitAndTools.git-filter-repo
      gitAndTools.git-open
    ];
    home.file.".gitconfig".text = with userConf; ''
      [user]
        email = ${user.email}
        name = ${user.displayName}
      [url "ssh://git@github.com/uLabSystems/"]
        insteadOf = https://github.com/uLabSystems/
      [url "ssh://git@github.com/mwdavisii/"]
        insteadOf = https://github.com/mwdavisii/
      [init]
        defaultBranch = main
      '';  
  };
}