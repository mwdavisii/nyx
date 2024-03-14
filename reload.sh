#!/run/current-system/sw/bin/bash

osName=$(uname -s)
hostName=$(uname -n)
userName=$(whoami)

if [[ $osName == "Darwin" ]]; then
  darwin-rebuild switch --flake .
elif [[ $userName == "nix-on-droid"]] them
  nix-on-droid switch --flake .
else
  sudo nixos-rebuild switch --flake .
  pkill gpg-agent #force any changes to gpg
fi
