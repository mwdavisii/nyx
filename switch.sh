osName=$(uname -s)
hostName=$(uname -n)
userName=$(whoami)

if [[ $osName == "Darwin" ]]; then
  if [ -f /usr/local/bin/warp-cli ]; then
    # disable because nixos.org certs aren't trusted.
    warp-cli disconnect
  fi
  sudo --preserve-env=SSH_AUTH_SOCK darwin-rebuild switch --flake .
elif [[ $userName == "nix-on-droid" ]]; then
  nix-on-droid switch --show-trace --flake .
elif [ -f /etc/arch-release ]; then
  home-manager switch --show-trace --flake .#$hostName
else
  sudo nixos-rebuild switch --show-trace --flake .#$hostName
fi
