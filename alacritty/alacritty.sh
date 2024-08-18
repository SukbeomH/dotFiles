#!/bin/bash

# Backup the alacritty
echo "Backing up the alacritty..."
cp -r /Users/$USER/.config/alacritty /Users/$USER/Desktop/dotFile/alacritty

# Exit the script
exit 0