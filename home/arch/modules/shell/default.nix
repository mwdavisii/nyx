{ config, lib, ... }:

with lib;
let
  cfg = config.nyx.modules.shell.zsh;
in
{
  # On Arch the TTY login shell reads $ZDOTDIR/.zprofile and $ZDOTDIR/.zshrc.
  # The shared zsh module sets ZDOTDIR="$HOME/.config/zsh" but doesn't provide
  # the files at that path — symlink them here so the login flow (and ultimately
  # `exec Hyprland`) actually runs.
  config = mkIf cfg.enable {
    xdg.configFile."zsh".source = ../../../config/.config/zsh;
  };
}
