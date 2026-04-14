{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.shell.weechat;

  weechat-soju = pkgs.stdenv.mkDerivation {
    pname = "weechat-soju";
    version = "0.5.1";
    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/weechat/scripts/main/python/soju.py";
      sha256 = "0lbsm6qcks7ispi3drp5qcj2ixkzlaq83fq474mxw7cbylxjg9kl";
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share
      cp $src $out/share/soju.py
    '';
  };
in
{
  options.nyx.modules.shell.weechat = {
    enable = mkEnableOption "weechat IRC client";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ weechat ];

    home.file.".weechat/python/autoload/soju.py".source =
      "${weechat-soju}/share/soju.py";
  };
}
