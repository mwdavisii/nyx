{ config, lib, pkgs, userConf, agenix, secrets, ... }:
with lib;
let 
    cfg = config.nyx.secrets.awsSSHKeys;
    homePath = if pkgs.stdenv.isDarwin then "/Users/${userConf.userName}" else "/home/${userConf.userName}";
in
{
    options.nyx.secrets.awsSSHKeys = {
        enable = mkEnableOption "Enable AWS Config Decryption";
    };

    config = mkIf cfg.enable {
        age.secrets.ulab_2017 = {
            file = "${secrets}/encrypted/ulab-2017-02-07.age";
            mode = "400";
            path =  "${homePath}/.ssh/aws/ulab-2017-02-07.pem";            
        }; 
        age.secrets.us-dev-us-west-2 = {
            file = "${secrets}/encrypted/us-dev-us-west-2.age";
            mode = "400";
            path =  "${homePath}/.ssh/aws/us-dev-us-west-2.pem";
        }; 
        age.secrets.us-prod-us-west-2 = {
            file = "${secrets}/encrypted/us-prod-us-west-2.age";
            mode = "400";
            path =  "${homePath}/.ssh/aws/us-prod-us-west-2.pem";
        }; 
        age.secrets.us-qa-us-west-2 = {
            file = "${secrets}/encrypted/us-qa-us-west-2.age";
            mode = "400";
            path =  "${homePath}/.ssh/aws/us-qa-us-west-2.pem";
            #owner = "${userConf.userName}";
        }; 
        age.secrets.us-shared-us-west-2 = {
            file = "${secrets}/encrypted/us-shared-us-west-2.age";
            mode = "400";
            path =  "${homePath}/.ssh/aws/us-shared-us-west-2.pem";
            #owner = "${userConf.userName}";
        }; 
    };
}