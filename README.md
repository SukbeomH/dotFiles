## Backup AND Restore

모든 경로에서 현재 레포지토리를 사용할 수 있도록 설정합니다.

```zsh
/Users/{USER}/Desktop/dotFile
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
mv Brewfile /Users/{USER}/Desktop/dotFile/homebrew
```

### 복원하기 위해서는 다음과 같이 진행합니다.

```zsh
# Move to the Brewfile directory
cd /Users/{USER}/Desktop/dotFile/homebrew

# Install the Homebrew Bundle
brew bundle
```

### Crontab을 사용하여 매일 백업합니다.

```zsh
# Open the crontab
crontab -e

# Add the following line (Backup the Homebrew Bundle everyday at 00:00)
0 0 * * * /Users/{USER}/Desktop/dotFile/homebrew/backup.sh
```
# dotFiles
