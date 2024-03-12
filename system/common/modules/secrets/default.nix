{ config, pkgs, agenix, secrets, userConf, ... }:

let 
    homePath = if pkgs.stdenv.isDarwin then "/Users/${userConf.userName}" else "/home/${userConf.userName}";
in
{
    age.identityPaths = [
    "${homePath}/.ssh/id_rsa"
    ];

    age.secrets.awsconfig = {
      symlink = true;
      file = "${secrets}/encrypted/aws.config.age";
      mode = "770";
      path =  "/home/${userConf.userName}/.aws/config";
      owner = "${userConf.userName}";
      group = "keys";
    };
    
    age.secrets.id_ed25519 = {
      symlink = true;
      file = "${secrets}/encrypted/id_ed25519.age";
      mode = "400";
      path =  "/home/${userConf.userName}/.ssh/id_ed25519";
      owner = "${userConf.userName}";
      group = "keys";
    };
    
    age.secrets.id_ed25519_pub = {
      symlink = true;
      file = "${secrets}/encrypted/id_ed25519.pub.age";
      mode = "400";
      path =  "/home/${userConf.userName}/.ssh/id_ed25519.pub";
      owner = "${userConf.userName}";
      group = "keys";
    };
    
    age.secrets.gpg_key = {
      symlink = true;
      file = "${secrets}/encrypted/gpg_key.age";
      mode = "400";
      path =  "/home/${userConf.userName}/.gnupg/gpg_pvt.asc";
      owner = "${userConf.userName}";
      group = "keys";
    };

    age.secrets.gpg_key_pub = {
      symlink = true;
      file = "${secrets}/encrypted/gpg_key.pub.age";
      mode = "400";
      path =  "/home/${userConf.userName}/.gnupg/gpg_pub.asc";
      owner = "${userConf.userName}";
      group = "keys";
    };
    
}