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

# install nix (Determinate Systems installer)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# fonts
git clone https://github.com/powerline/fonts.git --depth=1
./fonts/install.sh
rm -rf fonts