{ config, lib, pkgs, userConf, agenix, secrets, ... }:
with lib;
let 
    cfg = config.nyx.modules.secrets.awsConfig;
    homePath = if pkgs.stdenv.isDarwin then "/Users/${userConf.userName}" else "/home/${userConf.userName}";
in
{
    options.nyx.modules.secrets.awsConfig = {
        enable = mkEnableOption "Enable AWS Config Decryption";
    };

    config = mkIf cfg.enable {
        
        age.secrets.aws_config = {
            symlink = true;
            file = "${secrets}/encrypted/aws.config.age";
            mode = "770";
            path =  "${homePath}/.aws/config";
        }; 
    };
}