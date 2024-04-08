{ lib, ... }:

with builtins;
with lib;
{
  imports =
    [
      ./desktop
      ./apps
      ../../shared/modules
    ];
}
