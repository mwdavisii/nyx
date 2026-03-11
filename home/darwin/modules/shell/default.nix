{ config, lib, ... }:

with lib;
let
  cfg = config.nyx.modules.shell.zsh;
in
{
  # The shared zsh module sets ZDOTDIR="$HOME/.config/zsh" but doesn't place
  # config files at that path — symlink them here so macOS zsh finds them.
  config = mkIf cfg.enable {
    xdg.configFile."zsh".source = ../../../config/.config/zsh;
  };
}
