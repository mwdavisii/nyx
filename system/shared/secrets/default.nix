{ config, inputs, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.secrets;
in

{
  options.nyx.secrets = {
    enable = mkEnableOption "Secret Configurations";
  };

    import = [
        ./awsConfig.nix 
        ./userSSHKeys.nix 
        ./userPGPKeys.nix 
        ./awsSSHKeys.nix
    ];
}