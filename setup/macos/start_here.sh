# this is just helpful in re-install - it wipes the 
# backup files from previous installations.
#sudo rm -rf /etc/nix/nix.conf
#sudo launchctl unload /Library/LaunchDaemon/org.nixos.nix-daemon.plist
#sudo launchctl unload /Library/LaunchDaemons/org.nixos.activate-system.plist
#sudo diskutil apfs deleteVolume /nix
#sudo rm -rf /nix/

mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
#echo "build-users-group = nixbld" >> ~/.config/nix/nix.conf
rm ~/.bashrc ~/.zshrc

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# git-lfs needs to be on PATH and initialized before the first darwin-rebuild
# so tracked wallpapers land as real files rather than pointer stubs.
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install git-lfs
git lfs install --skip-repo
if git -C "$(dirname "$0")/../.." rev-parse --git-dir &>/dev/null; then
  git -C "$(dirname "$0")/../.." lfs install --local
  git -C "$(dirname "$0")/../.." lfs pull
fi

# install nix (Determinate Systems installer)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# fonts
git clone https://github.com/powerline/fonts.git --depth=1
./fonts/install.sh
rm -rf fonts