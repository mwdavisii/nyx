{ agenix, config, pkgs, userConf, inputs, lib, ... }:

with pkgs;
with inputs;
with lib;
{   
    imports = [
        ../../modules/dock
        ./dockConfig.nix
    ];

    config = {
        programs.zsh.enable = true;
        # Fully declarative dock using the latest from Nix Store
            ## Dock Configuration
        
        # Auto upgrade nix package and the daemon service.
        homebrew = {
            enable = true;
            casks = pkgs.callPackage ../../casks.nix {};
            brews = pkgs.callPackage ../../brews.nix {};

            # These app IDs are from using the mas CLI app
            # mas = mac app store
            # https://github.com/mas-cli/mas
            #
            # $ nix shell nixpkgs#mas
            # $ mas search <app name>
            #
            masApps = {
                "OneDrive" = 823766827;
                "Microsoft Word" = 462054704;
                "Microsoft Excel" = 462058435;
                "Microsoft Outlook" = 985367838;
                "Microsoft Power Point" = 462062816;
                "Keeper Password Manager" = 414781829;
                "Xcode" = 497799835;
            };
        };
        # Enable fonts dir
        
        system = {
            #stateVersion = 4;
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

                finder = {
                    _FXShowPosixPathInTitle = false;
                    AppleShowAllFiles = true;
                };

                trackpad = {
                    Clicking = true;
                    TrackpadThreeFingerDrag = true;
                };

                # Disable Mission Control shortcuts that conflict with Hammerspoon/PaperWM
                # 32 = Mission Control (Ctrl+Up), 33 = App Windows (Ctrl+Down)
                # 79/80 = Move left a space (Ctrl+Left), 81/82 = Move right a space (Ctrl+Right)
                CustomUserPreferences = {
                    "com.apple.symbolichotkeys" = {
                        AppleSymbolicHotKeys = {
                            "32" = { enabled = 0; };
                            "33" = { enabled = 0; };
                            "79" = { enabled = 0; };
                            "80" = { enabled = 0; };
                            "81" = { enabled = 0; };
                            "82" = { enabled = 0; };
                        };
                    };
                };
            };
        };
    };
}
