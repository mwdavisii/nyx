{ ... }:

{
  imports = [./system.nix];
  
  nyx = {
    modules = {
      user.home = ./home.nix;
    };
  };
}