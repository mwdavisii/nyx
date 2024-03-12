{ ... }:

{
  imports = [./system.nix];
  
  nyx = {
    modules = {
      user.home = ../../../../home/wsl2/home.nix;
    };
  };
}