osName=$(uname -s)
hostName=$(uname -n)
userName=$(whoami)

if [[ $osName == "Darwin" ]]; then
  if [ -f /usr/local/bin/warp-cli ]; then
    # disable because nixos.org certs aren't trusted.
    warp-cli disconnect
  fi
  sudo --preserve-env=SSH_AUTH_SOCK darwin-rebuild switch --flake .
  if [ $? -eq 0 ] && command -v sketchybar &>/dev/null; then
    brew services restart sketchybar
  fi
elif [[ $userName == "nix-on-droid" ]]; then
  nix-on-droid switch --show-trace --flake .
elif [ -f /etc/arch-release ]; then
  setup/arch/02-install-packages.sh --sync
  _HM_CMD="home-manager switch --show-trace --flake .#$hostName"
  if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    dbus-run-session bash -c "$_HM_CMD"
  else
    eval "$_HM_CMD"
  fi
else
  sudo nixos-rebuild switch --show-trace --flake .#$hostName
fi
