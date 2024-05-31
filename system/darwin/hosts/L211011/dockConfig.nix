{ agenix, config, pkgs, userConf, inputs, lib, ... }:

with pkgs;
with inputs;
with lib;
{
config = {
    local.dock = {
            enable = true;
            autohide = true;
            entries = [
            { path = "${pkgs.discord}/Applications/Discord.app/"; } 
            { path = "/Applications/Microsoft Outlook.app/"; }
            { path = "/Applications/Microsoft Teams.app/"; }
            { path = "/Applications/Google Chrome.app/"; }
            { path = "/Applications/Firefox.app/"; }
            { path = "/Applications/Safari.app/"; }
            { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
            { path = "${pkgs.kitty}/Applications/kitty.app/"; }
            { path = "${pkgs.vscode}/Applications/Visual Studio Code.app/"; }
            { path = "/Applications/Sublime Text.app/"; }
            ];
        };
    };
}
