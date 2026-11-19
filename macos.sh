#!/usr/bin/env bash
# macOS 기본 설정. ./install.sh --macos 또는 직접 실행한다.
# 모두 `defaults write` 라서 같은 키에 `defaults delete` 를 하면 원래대로 돌아간다.
set -euo pipefail

[[ "$(uname -s)" == "Darwin" ]] || { echo "macOS 에서만 실행합니다."; exit 0; }

echo "키보드"
defaults write NSGlobalDomain KeyRepeat -int 2                       # 키 반복 속도 (작을수록 빠름)
defaults write NSGlobalDomain InitialKeyRepeat -int 15               # 반복 시작까지 지연
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false   # 길게 누르면 악센트 메뉴 대신 반복

echo "입력 자동 교정 끄기"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

echo "Finder"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true      # 확장자 항상 표시
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"  # 검색 범위: 현재 폴더
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

echo "Dock"
defaults write com.apple.dock show-recents -bool false               # 최근 사용 앱 숨김
defaults write com.apple.dock mru-spaces -bool false                 # Space 자동 재정렬 끄기

killall Finder Dock >/dev/null 2>&1 || true
echo "완료. 키보드 설정은 로그아웃 후 다시 로그인해야 적용됩니다."
