{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.terraform;
in
{
  options.nyx.modules.shell.terraform = {
    enable = mkEnableOption "terraform configuration";
  };

  config = mkIf cfg.enable {
    home.packages = [ 
        pkgs.terraform
        pkgs.terraform-ls
        pkgs.tflint
    ];
  };
}
  
  
  

