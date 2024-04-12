{ agenix, config, pkgs, userConf, inputs, lib, ... }:

with pkgs;
with inputs;
with lib;
{
config = {
    local.dock = {
            enable = true;
            entries = [
            #{ path = "/Applications/Telegram.app/"; }
            { path = "/Applications/Discord.app/"; } 
            { path = "/Applications/Microsoft Outlook.app/"; }
            { path = "/Applications/Microsoft Teams (work or school).app/"; }
            { path = "/Applications/Google Chrome.app/"; }
            { path = "/Applications/Firefox.app/"; }
            { path = "/Applications/Safari.app/"; }
            { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
            { path = "${pkgs.kitty}/Applications/kitty.app/"; }
            { path = "/Applications/Visual Studio Code.app/"; }
            { path = "/Applications/Sublime Text.app/"; }
            { path = "/Applications/MySQLWorkbench.app/"; } 
            ];
        };
    };
}