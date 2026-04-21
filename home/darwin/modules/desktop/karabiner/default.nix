{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.karabiner;
  karabinerSource = ../../../../config/.config/karabiner;
in
{
  options.nyx.modules.desktop.karabiner = {
    enable = mkEnableOption "karabiner";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      karabiner-elements
    ];

    # Karabiner needs a writable config directory (it writes back keyboard type
    # selections on startup). Use activation script to copy instead of symlink.
    home.activation.karabinerConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      karabiner_dir="$HOME/.config/karabiner"
      mkdir -p "$karabiner_dir"
      cp -f "${karabinerSource}/karabiner.json" "$karabiner_dir/karabiner.json"
      chmod u+w "$karabiner_dir/karabiner.json"
    '';
  };
}
