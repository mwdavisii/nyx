sudo nix-channel --add https://nixos.org/channels/nixos-25.05 nixos
sudo nix-channel --update
nix-shell -p git vim