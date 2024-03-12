{ config, self, pkgs, agenix, secrets, userConf, ... }:

with self.lib;

let 
    cfg = config.nyx.modules.secrets;
    homePath = if pkgs.stdenv.isDarwin then "/Users/${userConf.userName}" else "/home/${userConf.userName}";
in
{
    options.nyx.modules.secrets = {
        enable = mkEnableOption "Enable Secrets Decryption";
        identityPath = mkOption {
            description = "Path to SSH Decryption Key";
            type = with types; nullOr str;
            default = "${homePath}/.ssh/id_rsa";
        };
    };

    config = mkIf cfg.enable {
        
        age.identityPaths = [
            cfg.identityPath
        ];
    };
    imports = [ ./awsConfig.nix ./userKeys.nix ./awsKeys.nix];
}
