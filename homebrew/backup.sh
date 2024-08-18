#!/bin/bash

# Today's date
today=$(date +"%Y-%m-%d")

# Enable the Homebrew Bundle
echo "Enabling the Homebrew Bundle..."
brew tap Homebrew/bundle

# Backup the Homebrew Bundle
echo "Backing up the Homebrew Bundle..."
brew bundle dump

# Move the Brewfile to the current directory
echo "Moving the Brewfile to the current directory..."
mv Brewfile /Users/$USER/Desktop/dotFile/homebrew

# Commit the changes to the repository
echo "Committing the changes to the repository..."
git add .
git commit -m "Backup the Homebrew Bundle on $today"
git push origin master

# Exit the script
exit 0
