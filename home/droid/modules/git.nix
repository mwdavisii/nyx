{ config, lib, pkgs, user, ... }:
{  
  home.packages = with pkgs; [
    git
    git-crypt
    delta
    gh
    glab
    git-filter-repo
    git-open
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