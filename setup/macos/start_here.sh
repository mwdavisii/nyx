# this is just helpful in re-install - it wipes the 
# backup files from previous installations.
#sudo rm -rf /etc/nix/nix.conf
#sudo launchctl unload /Library/LaunchDaemon/org.nixos.nix-daemon.plist
#sudo launchctl unload /Library/LaunchDaemons/org.nixos.activate-system.plist
#sudo diskutil apfs deleteVolume /nix
#sudo rm -rf /nix/

mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
echo "build-users-group = nixbld" >> ~/.config/nix/nix.conf
rm ~/.bashrc ~/.zshhrc

# install nixos
sh <(curl -L https://nixos.org/nix/install)

# fonts
git clone https://github.com/powerline/fonts.git --depth=1
./fonts/install.sh
rm -rf fonts