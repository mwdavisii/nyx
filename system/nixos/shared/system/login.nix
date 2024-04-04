{ config, lib, pkgs, modulesPath, hostName, userConf, ... }:
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
in
{

  programs.dconf.enable = true;
  programs.regreet.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${tuigreet} --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  #yubikey
  services.udev.packages = [ pkgs.yubikey-personalization ];
  #programs.yubico-pam = true;

  security = {
    sudo = {
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
    pam.yubico = {
      enable = true;
      mode = "challenge-response";
      id = userConf.yubiKeySerials;
    };
    pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };
    polkit.enable = true;
    rtkit.enable = true;
  };
}
