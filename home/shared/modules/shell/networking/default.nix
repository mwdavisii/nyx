{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.networking;
in
{
  options.nyx.modules.shell.networking = {
    enable = mkEnableOption "Kubernetes Tooling";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;[ 
        #coreutils-full
        inetutils
        nmap
        dig
        arp-scan
        net-tools
        netdiscover
        lldpd
        httpie
        mtr
        iperf3
        gobgp
    ];
  };
}