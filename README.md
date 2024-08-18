## Backup AND Restore

모든 경로에서 현재 레포지토리를 사용할 수 있도록 설정합니다.

```zsh
# Create the dotFile directory
mkdir /Users/$USER/Desktop/dotFile

# Move to the dotFile directory
cd /Users/$USER/Desktop/dotFile

# git clone the repository
git clone https://github.com/SukbeomH/dotFiles.git .

# pwd
/Users/$USER/Desktop/dotFile
```

라고 가정하고 진행합니다.

# Homebrew

### Homebrew를 사용하여 설치된 패키지를 백업합니다.

```zsh
# Enable the Homebrew Bundle
brew tap Homebrew/bundle

# Backup the Homebrew Bundle
brew bundle dump

# Move the Brewfile to the current directory
mv Brewfile /Users/$USER/Desktop/dotFile/homebrew
```

### Crontab을 사용하여 매일 백업합니다.

```zsh
# Open the crontab
crontab -e

# Add the following line (Backup the Homebrew Bundle everyday at 00:00)
0 0 * * * /Users/$USER/Desktop/dotFile/homebrew/backup.sh
```

### 복원하기 위해서는 다음과 같이 진행합니다.

```zsh
# Move to the Brewfile directory
cd /Users/$USER/Desktop/dotFile/homebrew

# Install the Homebrew Bundle
brew bundle --file=/Users/$USER/Desktop/dotFile/homebrew/Brewfile
```

# Fonts

### 폰트를 백업합니다.

```zsh
# Copy the fonts to the current directory
cp -r /Users/$USER/Library/Fonts /Users/$USER/Desktop/dotFile/fonts
```

### 백업된 폰트를 복원합니다.

```zsh
# Copy the fonts to the Library directory
cp -r /Users/$USER/Desktop/dotFile/fonts /Users/$USER/Library/Fonts
```

# Shell :: iTerm2

### iTerm2 설정을 백업합니다.

```zsh
# Sync the iTerm2 settings to the dotFile directory
cp -r /Users/$USER/Library/Preferences/com.googlecode.iterm2.plist /Users/$USER/Desktop/dotFile/iterm2
```

### 백업된 iTerm2 설정을 복원합니다.

```zsh
# Sync the iTerm2 settings to the Library directory
cp -r /Users/$USER/Desktop/dotFile/iterm2/com.googlecode.iterm2.plist /Users/$USER/Library/Preferences
```

### 혹은 다음과 같이 진행합니다.

- iTerm2 > Preferences > General > Settings
  - Load settings from a custom folder or URL <= Check ✅
  - Specify folder <= `/Users/$USER/Desktop/dotFile/iterm2`
  - Save Current Settings to Folder <= Click 💾
  - Save Changes <= **Automatically** ♻️

# Shell :: Alacritty

### Alacritty 설정을 백업합니다.

```zsh
# Copy the Alacritty settings to the dotFile directory
cp -r /Users/$USER/.config/alacritty /Users/$USER/Desktop/dotFile/alacritty
```

### 백업된 Alacritty 설정을 복원합니다.

```zsh
# Copy the Alacritty settings to the config directory
cp -r /Users/$USER/Desktop/dotFile/alacritty /Users/$USER/.config
```

# Shell :: Zsh

### Zsh 설정을 백업합니다.

```zsh
# Copy the Zsh settings to the dotFile directory
cp -r /Users/$USER/.zshrc /Users/$USER/Desktop/dotFile/zsh/.zshrc
```

### 백업된 Zsh 설정을 복원합니다.

```zsh
# Copy the Zsh settings to the home directory
cp -r /Users/$USER/Desktop/dotFile/zsh/.zshrc /Users/$USER
```

# Script

`backup.sh` 파일을 통해 백업을 진행합니다.

```zsh
sh /Users/$USER/Desktop/dotFile/backup.sh
```
