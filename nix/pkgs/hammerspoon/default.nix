{ pkgs, fetchurl, ... }:
with pkgs;
with pkgs.lib;
# This cannot be built from source since Hammerspoon requires entitlements to work,
# and codesigning entitlements is unfortunately incompatible with immutability.
  stdenv.mkDerivation rec {
    pname = "hammerspoon";
    version = "0.9.100";

    # We don't use fetchzip because that seems to unpack the .app as well.
    src = fetchurl {
      name = "${pname}-${version}-source.zip";
      url = "https://github.com/Hammerspoon/hammerspoon/releases/download/${version}/Hammerspoon-${version}.zip";
      sha256 = "sha256-bc/IB8fOxpLK87GMNsweo69rn0Jpm03yd3NECOTgc5k=";
    };

    nativeBuildInputs = [
      # Adds unpack hook.
      unzip
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      cp -r ../Hammerspoon.app $out/Applications/
      runHook postInstall
    '';

    meta = {
      homepage = "https://www.hammerspoon.org";
      description = "Staggeringly powerful macOS desktop automation with Lua";
      license = lib.licenses.mit;
      platforms = [ "x86_64-darwin" "aarch64-darwin" ];
    };
  }