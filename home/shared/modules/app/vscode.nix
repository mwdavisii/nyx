{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.vscode;
in
{
  options.nyx.modules.app.vscode = {
    enable = mkEnableOption "VS Code Install";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      vscode
    ];
  };
}