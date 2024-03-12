{ config, self, pkgs, agenix, secrets, userConf, ... }:

with self.lib;

let 
    cfg = config.nyx.modules.secrets.includeAWSConfig;
    homePath = if pkgs.stdenv.isDarwin then "/Users/${userConf.userName}" else "/home/${userConf.userName}";
in
{
    options.nyx.modules.secrets.includeAWSConfig = {
        enable = mkEnableOption "Enable AWS Config Decryption";
    };

    config = mkIf cfg.enable {
        age.secrets.aws_config = {
            symlink = true;
            file = "${secrets}/encrypted/aws.config.age";
            mode = "770";
            path =  "/home/${userConf.userName}/.aws/config";
            owner = "${userConf.userName}";
            group = "keys";
        }; 
    };
}