#!/bin/bash
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

#install home manager
nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager
nix-channel --update

# install nix-darwin
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer


# fonts
git clone https://github.com/powerline/fonts.git --depth=1
./fonts/install.sh
rm -rf fonts


# VIM Plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'