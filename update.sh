osName=$(uname -s)
hostName=$(uname -n)
userName=$(whoami)

nix flake update

if [[ $osName == "Darwin" ]]; then
  brew upgrade
  if [ -f /usr/local/bin/warp-cli ]; then
    # disable because nixos.org certs aren't trusted.
    warp-cli disconnect
  fi
  sudo --preserve-env=SSH_AUTH_SOCK darwin-rebuild switch --flake .
elif [[ $userName == "nix-on-droid" ]]; then
  nix-on-droid switch --show-trace --flake .
elif [ -f /etc/arch-release ]; then
  sudo pacman -Syu --noconfirm
  if command -v yay &>/dev/null; then
    yay -Syu --noconfirm
  fi
  setup/arch/02-install-packages.sh --sync
  home-manager switch --show-trace --flake .#$hostName
else
  sudo nixos-rebuild switch --show-trace --flake .#$hostName
fi
