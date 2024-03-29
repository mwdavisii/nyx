{ config, lib, pkgs, modulesPath, hostName, ... }:
{
    imports =
        [ # Include the results of the hardware scan.
        ./hardware.nix
        ];

    #networking.hostName = $hostName; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;
    #nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    # Enable networking
    # networking.wireless.enable  = lib.mkForce false;
    networking.networkmanager.enable = lib.mkForce true;
    networking.useDHCP = lib.mkDefault true;

    # Set your time zone.
    time.timeZone = "America/Chicago";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
    };

    # Configure keymap in X11
    services = {
        xserver = {
            enable = true;
            desktopManager.gnome.enable = true;
            layout = "us";
            xkbVariant = "";
            libinput.enable = true;
            #displayManager.lightdm = {
            #    enable = true;
            #    greeters.slick.enable = true;
            #};
            windowManager.bspwm = {
                enable = true;
            };
        };
        printing.enable = true;
        openssh.enable = true;
        gvfs.enable = true; # Mount, trash, and other functionalities
        tumbler.enable = true;
        pipewire = {
            enable = true;
            alsa = {
                enable = true;
                support32Bit = true;
            };
            pulse.enable = true;
        };
    };

    # Enable sound with pipewire.
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;

    security.sudo = {
        extraRules = [
            {
                commands = [
                    {
                        command = "ALL";
                        options = [ "NOPASSWD" ];
                    }
                ];
                groups = [ "wheel" ];
            }
        ];
    };
}
