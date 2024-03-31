{ config, lib, pkgs, modulesPath, hostName, ... }:
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
in
{
  security.polkit.enable = true;
  security.rtkit.enable = true;
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
    pam.services.swaylock = {
      text = ''
        aith include login
      '';
    };
  };git 
}
