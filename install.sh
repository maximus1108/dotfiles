#!/usr/bin/env bash

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install git
brew install git

# Clone this repo
git clone https://github.com/maximus1108/dotfiles.git ~/.dotfiles

