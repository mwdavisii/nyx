osName=$(uname -s)
hostName=$(uname -n)
userName=$(whoami)

if [[ $osName == "Darwin" ]]; then
  darwin-rebuild switch --flake .
elif [[ $userName == "nix-on-droid" ]]; then
  nix-on-droid switch --flake .
else
  sudo nixos-rebuild switch --flake .#$hostName
  #pkill gpg-agent #force any changes to gpg
fi
