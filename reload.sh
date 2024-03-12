#!/run/current-system/sw/bin/bash

osName=$(uname -s)
hostName=$(uname -n)

if [[ $osName == "Darwin" ]]; then
  darwin-rebuild switch --flake .
else
  sudo nixos-rebuild switch --flake .
fi
