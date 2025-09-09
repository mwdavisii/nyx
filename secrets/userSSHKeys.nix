{ config, lib, pkgs, userConf, agenix, secrets, ... }:
with lib;
let  
    cfg = config.nyx.secrets.userSSHKeys;
    homePath = if pkgs.stdenv.isDarwin then "/Users/${userConf.userName}" else "/home/${userConf.userName}";
in
{
    options.nyx.secrets.userSSHKeys = {
        enable = mkEnableOption "Enable User SSH Key Decryption";
    };

    config = mkIf cfg.enable {
        age.secrets.id_ed25519 = {
            symlink = true;
            file = "${secrets}/encrypted/id_ed25519.age";
            mode = "400";
            path =  "${homePath}/.ssh/id_ed25519";
            owner= "${userConf.userName}";
        };
    };
}

