  let
    pkgs = import <nixpkgs> { };

    kmonad-bin = pkgs.fetchurl {
      url = "https://github.com/kmonad/kmonad/releases/download/0.4.2/kmonad";
      sha256 = "0j73dzsfnsa7s96gnxhy9v2wz4l8pln0safdlbkz5j4gdasz3lsl";
    };
  in
  pkgs.runCommand "kmonad" {}
      ''
        #!${pkgs.stdenv.shell}
        mkdir -p $out/bin
        cp ${kmonad-bin} $out/bin/kmonad
        chmod +x $out/bin/*
      ''