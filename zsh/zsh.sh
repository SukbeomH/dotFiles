#!/bin/bash

# Backup the zsh
echo "Backing up the zsh..."
cp -r /Users/$USER/.zshrc /Users/$USER/Desktop/dotFile/zsh
cp -r /Users/$USER/.zprofile /Users/$USER/Desktop/dotFile/zsh

# Exit the script
exit 0