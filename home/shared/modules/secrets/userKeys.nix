{ config, lib, pkgs, userConf, agenix, secrets, ... }:
with lib;
let  
    cfg = config.nyx.modules.secrets.userKeys;
    homePath = if pkgs.stdenv.isDarwin then "/Users/${userConf.userName}" else "/home/${userConf.userName}";
in
{
    options.nyx.modules.secrets.userKeys = {
        enable = mkEnableOption "Enable User Key Decryption";
    };

    config = mkIf cfg.enable {
        age.secrets.id_ed25519 = {
            symlink = true;
            file = "${secrets}/encrypted/id_ed25519.age";
            mode = "400";
            path =  "${homePath}/.ssh/id_ed25519";
            #owner = "${userConf.userName}";
            #group = "wheel";
        };
        
        age.secrets.id_ed25519_pub = {
            symlink = true;
            file = "${secrets}/encrypted/id_ed25519.pub.age";
            mode = "400";
            path =  "${homePath}/.ssh/id_ed25519.pub";
            #owner = "${userConf.userName}";
            #group = "wheel";
        };
        
        age.secrets.gpg_key = {
            symlink = true;
            file = "${secrets}/encrypted/gpg_key.age";
            mode = "400";
            path =  "${homePath}/.gnupg/gpg_pvt.key";
            #owner = "${userConf.userName}";
            #group = "wheel";
        };

        age.secrets.gpg_key_pub = {
            symlink = true;
            file = "${secrets}/encrypted/gpg_key.pub.age";
            mode = "400";
            path =  "${homePath}/.gnupg/gpg_pub.key";
            #owner = "${userConf.userName}";
            #group = "wheel";
        };
    };
}

