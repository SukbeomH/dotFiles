#!/bin/bash

# Backup the homebrew
echo "Backing up the homebrew..."
sh homebrew/homebrew.sh
sleep 1

# Backup the zsh
echo "Backing up the zsh..."
sh zsh/zsh.sh
sleep 1

# Backup the iterm2
echo "Backing up the iterm2..."
sh iterm2/iterm2.sh
sleep 1

# Backup the alacritty
echo "Backing up the alacritty..."
sh alacritty/alacritty.sh
sleep 1

# Backup the fonts
echo "Backing up the fonts..."
sh fonts/fonts.sh
sleep 1

# today's date
today=$(date +"%Y-%m-%d")

# Push the changes to the remote repository
echo "Pushing the changes to the remote repository..."
git add .
git commit -m "Backup the dotfiles on $today"
git push origin master

# Exit the script
exit 0