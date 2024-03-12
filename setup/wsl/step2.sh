#!/run/current-system/sw/bin/bash
sudo nix-channel --add https://nixos.org/channels/nixos-23.11 nixos
sudo nix-channel --update
nix-shell -p git vim