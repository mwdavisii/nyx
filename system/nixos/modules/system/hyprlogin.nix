{ config, lib, pkgs, modulesPath, hostName, userConf, ... }:
with lib;
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  cfg = config.nyx.modules.system.hyprlogin;
in
{
  options.nyx.modules.system.hyprlogin = { 
    enable = mkEnableOption "Include Hyprland Login Service"; 
  };
  config = mkIf cfg.enable {
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
          auth include login
        '';
      };
      polkit.enable = true;
      rtkit.enable = true;
    };
  };
}
