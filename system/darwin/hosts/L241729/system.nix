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
                "Microsoft Excel" = 462058435;
                "Microsoft Power Point" = 462062816;
                "Microsoft Outlook" = 985367838;
                "Microsoft To Do" = 1274495053;
                "Microsoft Word" = 462054704;
                "Keeper Password Manager" = 414781829;
            };
        };
        system = {
            stateVersion = 5;
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
            };
        };
    };
}
