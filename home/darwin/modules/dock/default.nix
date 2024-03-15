{ config, inputs, pkgs, ... }:
let
  dock = import  ./dockConfig.nix;
in

{
        # Dock Items
    local = {
    dock.enable = true;
    dock.entries = [
        { path = "/Applications/Telegram.app/"; }
        { path = "/Applications/Discord.app/"; } 
        { path = "/Applications/Microsoft Outlook.app/"; }
        { path = "/Applications/Microsoft Teams (work or school).app/"; }
        { path = "/Applications/Google Chrome.app/"; }
        { path = "/Applications/Firefox.app/"; }
        { path = "/Applications/Safari.app/"; }
        { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
        { path = "/Applications/iTerm.app/"; }
        { path = "/Applications/Visual Studio Code.app/"; }
        { path = "/Applications/Sublime Text.app/"; }
        { path = "/Applications/MySQLWorkbench.app/"; } 
    ];
    };
    system = {
        stateVersion = 4;
        defaults = {
        LaunchServices = {
            LSQuarantine = false;
        };

        NSGlobalDomain = {
            AppleShowAllExtensions = true;
            ApplePressAndHoldEnabled = false;

            # 120, 90, 60, 30, 12, 6, 2
            KeyRepeat = 2;

            # 120, 94, 68, 35, 25, 15
            InitialKeyRepeat = 15;

            "com.apple.mouse.tapBehavior" = 1;
            "com.apple.sound.beep.volume" = 0.0;
            "com.apple.sound.beep.feedback" = 0;
        };

        dock = {
            autohide = false;
            show-recents = false;
            launchanim = true;
            mouse-over-hilite-stack = true;
            orientation = "bottom";
            tilesize = 48;
        };

        finder = {
            _FXShowPosixPathInTitle = false;
        };

        trackpad = {
            Clicking = true;
            TrackpadThreeFingerDrag = true;
        };
        };

        keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
        };
    };
}