#!/bin/bash

echo '*** Install Homebrew'
sleep 1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') > ~/.zprofile
source ~/.zprofile

echo '*** Install App Store CLI'
sleep 1
brew install mas

echo '*** Update App Store packages'
sleep 1
mas upgrade

echo '*** Install Git'
sleep 1
brew install git
brew install git-lfs
git lfs install

echo '*** Cloning dotfiles repository'
sleep 1
[ ! -d ~/git ] && mkdir ~/git
cd ~/git
[ ! -d dotfiles ] && git clone git@github.com:borgiman/dotfiles.git

echo '*** Set Git config'
sleep 1
ln -s -f ~/git/dotfiles/git/.gitconfig ~/.gitconfig

echo '*** Install GitHub CLI'
sleep 1
brew install gh

echo '*** Generate SSH key for GitHub'
sleep 1
if [ ! -f ~/.ssh/id_ed25519_github ]; then
    [ ! -d ~/.ssh ] && mkdir ~/.ssh
    ssh_passphrase=$(dd if=/dev/urandom bs=16 count=1 2>/dev/null | base64 | sed 's/=//g')
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github -P $ssh_passphrase
    eval "$(ssh-agent -s)"
    echo 'eval "$(ssh-agent -s)"' >> ~/.zshrc
    [ ! -f ~/.ssh/config ] && touch ~/.ssh/config
    if ! grep -q "github.com" ~/.ssh/config; then
        echo 'Host github.com' >> ~/.ssh/config
        echo '    AddKeysToAgent yes' >> ~/.ssh/config
        echo '    UseKeychain yes' >> ~/.ssh/config
        echo '    IdentityFile ~/.ssh/id_ed25519_github' >> ~/.ssh/config
    fi
    echo '---> SSH passphrase' $ssh_passphrase
    echo $ssh_passphrase | ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github
    gh auth login --git-protocol ssh --hostname github.com --skip-ssh-key --web --scopes "admin:public_key"
    gh ssh-key add ~/.ssh/id_ed25519_github.pub --title "MacBook"
fi

echo '*** Install Microsoft Teams'
sleep 1
brew install --cask microsoft-teams

echo '*** Install Google Chrome'
sleep 1
brew install --cask google-chrome

echo '*** Enable dark mode'
sleep 1
osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'

echo '*** Set trackpad speed'
sleep 1
defaults write -g com.apple.trackpad.scaling 1.5

echo '*** Disable tap to click'
sleep 1
defaults write com.apple.AppleMultiTouchTrackpad Clicking -bool False

echo '*** Set click force to light'
sleep 1
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 0

echo '*** Set max charge capacity to 80%'
sleep 1
brew tap zackelia/formulae
brew install bclm
sudo bclm write 80
sudo bclm persist

echo '*** Configure dock'
sleep 1
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Microsoft Teams (work or school).app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Google Chrome.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Utilities/Terminal.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
killall Dock
