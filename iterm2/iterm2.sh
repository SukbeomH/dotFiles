#!/bin/bash

# Backup the iterm2
echo "Backing up the iterm2..."
cp -r /Users/$USER/Library/Preferences/com.googlecode.iterm2.plist /Users/$USER/Desktop/dotFile/iterm2

# Exit the script
exit 0