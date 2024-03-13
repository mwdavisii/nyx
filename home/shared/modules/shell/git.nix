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
    
    inheritUser = mkOption {
      type = types.bool;
      default = true;
      description = "Inherit username, email and signingKey from user";
    };

    signing = mkOption {
      type = signModule;
      default = { };
      description = "Options related to signing commits using GnuPG.";
    };
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
    
    home.file.".gitconfig".text=
    let
      firstOrDefault = x: y: if !isNull x then x else if cfg.inheritUser then y else null;
      username = user.displayName;
      email = user.email;
      signkey = firstOrDefault cfg.signing.key (if hasAttr "signingKey" user then user.signingKey else null);
      signByDefault = (!isNull signkey) || cfg.signing.signByDefault;      
  in
      ''  
      [init]
        defaultBranch = main
      [url "ssh://git@github.com/uLabSystems/"]
        insteadOf = https://github.com/uLabSystems/
      [url "ssh://git@github.com/mwdavisii/"]
        insteadOf = https://github.com/mwdavisii/
      [user]
        name = "${username}"
        email = "${email}"
      ${if isNull signkey then "" else ''
        signingKey = "${signkey}"''}
      ${if !signByDefault then "" else ''
      [commit]
        gpgSign = true
      [tag]
        gpgSign = true''}
      [gpg]
        program = ${cfg.signing.gpgPath}
      '';
  };
}