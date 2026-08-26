{ config, pkgs, lib, inputs, ... }:

# hestia — agent-run M1 MacBook (Hermes), standalone home-manager.
#
# NO SECRETS ON THIS HOST. nyx.secrets.* is not merely disabled here — those
# options are defined only in system/shared/secrets/*.nix (system-level
# modules), which the standalone Darwin builder never imports. Setting them
# to false would be an eval error: the options do not exist in this scope.
# That absence is the guarantee. Do not import system/shared/secrets, do not
# define age.secrets. Matches headless.nix / prometheus / L242731 behavior.
#
# The only credential on this machine is the pre-existing ~/.ssh/id_ed25519,
# which nyx does not manage.

{
  programs.home-manager.enable = true;
  programs.man.enable = true;
  manual.manpages.enable = true;

  home = {
    stateVersion = "26.05";
    packages = with pkgs; [ ];
  };
}
