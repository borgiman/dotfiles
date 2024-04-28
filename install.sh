#!/bin/bash

echo '*** Install Homebrew'
sleep 1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') > ~/.zprofile
source ~/.zprofile

echo '*** Install Git'
sleep 1
brew install git

echo '*** Set Git config'
sleep 1
git config --global user.name "Patrick Borgogno"
git config --global user.email "789401+borgiman@users.noreply.github.com"

echo '*** Generate SSH key for GitHub'
sleep 1
if [ ! -f ~/.ssh/id_ed25519_github ]; then
    [ ! -d ~/.ssh ] && mkdir ~/.ssh
    ssh_passphrase=$(dd if=/dev/urandom bs=16 count=1 2>/dev/null | base64 | sed 's/=//g')
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github -P $ssh_passphrase
    eval "$(ssh-agent -s)"
    echo 'eval "$(ssh-agent -s)"' >> ~/.zshrc
    [ ! -f ~/.ssh/config ] && touch ~/.ssh/config
    if [ ! grep -q "github.com" ~/.ssh/config ]; then
        echo 'Host github.com' >> ~/.ssh/config
        echo '    AddKeysToAgent yes' >> ~/.ssh/config
        echo '    UseKeychain yes' >> ~/.ssh/config
        echo '    IdentityFile ~/.ssh/id_ed25519_github' >> ~/.ssh/config
    fi
    echo '---> SSH passphrase' $ssh_passphrase
    echo $ssh_passphrase | ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github
    cat ~/.ssh/id_ed25519_github.pub
    echo '---> Copy the public key from the last line and add it to the ssh keys on github.com. Press Enter when finished'
    read
fi

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
