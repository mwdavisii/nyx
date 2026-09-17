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
  if [ -e /run/current-system ] || command -v darwin-rebuild &>/dev/null; then
    # nix-darwin host -> flake darwinConfigurations (mwdavis-workm1, L241729, EU-L260076).
    sudo --preserve-env=SSH_AUTH_SOCK darwin-rebuild switch --flake .
  else
    # Standalone home-manager host without nix-darwin -> flake homeConfigurations
    # (hestia). Requires an explicit .#$hostName; there is no default.
    home-manager switch --show-trace -b backup --flake .#$hostName
  fi
elif [[ $userName == "nix-on-droid" ]]; then
  nix-on-droid switch --show-trace --flake .
elif [ -f /etc/arch-release ]; then
  sudo pacman -Syu --noconfirm
  if command -v yay &>/dev/null; then
    _SYSPATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin
    _PKGCFG=/usr/lib/pkgconfig:/usr/share/pkgconfig
    PKG_CONFIG_PATH="$_PKGCFG" PATH="$_SYSPATH" yay -Syu --noconfirm
  fi
  setup/arch/02-install-packages.sh --sync
  _HM_CMD="home-manager switch --show-trace --flake .#$hostName"
  if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    dbus-run-session bash -c "$_HM_CMD"
  else
    eval "$_HM_CMD"
  fi
elif [ -f /etc/dgx-release ] || grep -qi 'dgx' /etc/os-release 2>/dev/null; then
  sudo apt-get update
  sudo apt-get -y upgrade
  setup/dgx/01-install-packages.sh --sync
  home-manager switch --show-trace --flake .#$hostName
else
  sudo nixos-rebuild switch --show-trace --flake .#$hostName
fi
