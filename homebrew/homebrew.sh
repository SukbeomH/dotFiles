#!/bin/bash

# Enable the Homebrew Bundle
echo "Enabling the Homebrew Bundle..."
brew tap Homebrew/bundle

# Backup the Homebrew Bundle
echo "Backing up the Homebrew Bundle..."
brew bundle dump

# Move the Brewfile to the current directory
echo "Moving the Brewfile to the current directory..."
mv Brewfile /Users/$USER/Desktop/dotFile/homebrew/

# Exit the script
exit 0
