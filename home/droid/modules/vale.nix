{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    vale
  ];
  home.file = {
    ".config/vale" = {
      source = ../../config/.config/vale;
      recursive = true;
    };
  };
}
