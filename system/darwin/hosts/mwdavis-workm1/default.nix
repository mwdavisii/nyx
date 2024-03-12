{ ... }:

{
  imports = [./system.nix];
  
  nyx = {
    modules = {
      user.home = ../../../../home/darwin/home.nix;
    };
  };
}