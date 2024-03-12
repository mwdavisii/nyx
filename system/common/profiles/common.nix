{ agenix, config, pkgs, userConf, inputs, lib, ... }:

with pkgs;
with inputs;
with lib;
{
    nyx.modules = {
        secrets = {
            enable = true;
            includeAWSKeys.enable = false;
            includeAWSConfig.enable = true;
        };
    };
}