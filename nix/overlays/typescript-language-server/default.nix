{ inputs, ... }:
final: prev:

# nixpkgs-unstable pins a stale pnpmDeps hash for typescript-language-server 6.0.2.
# Upstream broke after a pnpm bump: the pinned hash no longer matches the fetched
# dependency set, so `nix flake update` keeps pulling a broken package (the stale
# hash is still present at nixos-unstable HEAD as of this change). Override the
# hash with the value Nix reports until nixpkgs ships the corrected hash upstream;
# then drop this overlay.
{
  typescript-language-server = prev.typescript-language-server.overrideAttrs (old: {
    pnpmDeps = final.fetchPnpmDeps {
      inherit (old) pname version src;
      pnpm = final.pnpm_12;
      fetcherVersion = 4;
      hash = "sha256-xR/EF60lVBsITKgH7wCM2wHM46PFQevD51KfCENSUH4=";
    };
  });
}
