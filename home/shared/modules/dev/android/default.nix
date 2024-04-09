{ config, pkgs, lib, inputs, ... }:
with lib;
let 
    cfg = config.nyx.modules.dev.androidSDK;
    #android-sdk = inputs.android-nixpkgs.hmModule;
in
{
    options.nyx.modules.dev.androidSDK = {
        enable = mkEnableOption "Android SDK Configuration";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            android-tools
        ];
    };
}