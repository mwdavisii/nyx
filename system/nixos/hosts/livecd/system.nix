{ config, lib, pkgs, modulesPath, hostName, ... }:
{
    imports =
        [ # Include the results of the hardware scan.
        ./hardware.nix
        ];
    isoImage.volumeID = lib.mkForce "my-nixos-live";
    isoImage.isoName = lib.mkForce "my-nixos-live.iso";
    # Use zstd instead of xz for compressing the liveUSB image, it's 6x faster and 15% bigger.
    isoImage.squashfsCompression = "zstd -Xcompression-level 6";
    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    ## FIX for running out of space / tmp, which is used for building
    fileSystems."/nix/.rw-store" = {
        fsType = "tmpfs";
        options = [ "mode=0755" "nosuid" "nodev" "relatime" "size=14G" ];
        neededForBoot = true;
    };
    #networking.hostName = $hostName; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
# networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;
    #nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    # Enable networking
    networking.wireless.enable  = lib.mkForce false;
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
        # LightDM Display Manager
        #displayManager.defaultSession = "none+bspwm";
        #displayManager.lightdm = {
        #    enable = true;
        #    greeters.slick.enable = true;
        #};
        # Tiling window manager
        #windowManager.bspwm = {
        #    enable = true;
        #};
    };

    # Enable sound with pipewire.
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;

}
