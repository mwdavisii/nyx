{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.dev.go;
in
{
  options.nyx.modules.dev.go = { enable = mkEnableOption "go configuration"; };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        go
        go-swag
        # linters and static analysis
        go-tools
        delve
      ];

      sessionVariables = {
        GOPATH = "${config.xdg.dataHome}/go";
        GOBIN = "${config.xdg.dataHome}/go/bin";
      };
    };
  };
}

