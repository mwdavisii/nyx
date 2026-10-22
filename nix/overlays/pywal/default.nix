{ inputs, ... }:
final: prev:

let
  inherit (prev) lib;
in
{
  # nixos-unstable (as of the locked rev) ships pywal16 with a single-string
  # `makeWrapperArgs = [ "--prefix PATH : <imagemagick>/bin" ]`. The new
  # structured-attrs stdenv + make-shell-wrapper-hook passes each list element
  # to makeWrapper as a single, un-split argument, so makeWrapper sees the whole
  # string as one token and dies with:
  #   makeWrapper doesn't understand the arg --prefix PATH : <path>
  # Tokenize the args until nixpkgs catches up upstream.
  pywal16 = prev.pywal16.overrideAttrs (old: {
    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath [ prev.imagemagick ])
    ];
  });

  # `pywal` is an alias for `pywal16` (top-level/aliases.nix, added 2026-02-01);
  # point it at the fixed derivation explicitly so every `pkgs.pywal` user picks
  # it up.
  pywal = final.pywal16;
}
