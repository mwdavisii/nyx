{ config, lib, pkgs, user, ... }:
{  
  home.packages = with pkgs; [
    git
    gitAndTools.git-crypt
    gitAndTools.delta
    gitAndTools.gh
    gitAndTools.glab
    gitAndTools.git-filter-repo
    gitAndTools.git-open
  ];

  home.file.".gitconfig".text=
  let
    username = user.displayName;
    email = user.email;
  in
    ''  
    [init]
      defaultBranch = main
    [user]
      name = "${username}"
      email = "${email}"
    '';
}