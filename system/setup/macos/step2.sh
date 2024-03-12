#!/bin/bash

# Build my profile
nix build .#darwinConfigurations.mwdavis-workm1.system --extra-experimental-features "nix-command flakes"
./result/sw/bin/darwin-rebuild switch --flake