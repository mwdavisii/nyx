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
    [url "ssh://git@github.com/uLabSystems/"]
      insteadOf = https://github.com/uLabSystems/
    [url "ssh://git@github.com/mwdavisii/"]
      insteadOf = https://github.com/mwdavisii/
    [user]
      name = "${username}"
      email = "${email}"
    '';
}