{ ... }:

{
  imports = [./system.nix];
  
  nyx = {
    modules = {
      user.home = ../../../../home/droid/home.nix;
    };
  };
}