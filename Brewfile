# 기본 구성: CLI, macOS 앱과 폰트
# 사용: brew bundle --file=Brewfile

# --- 셸 ---
brew "starship"                       # 프롬프트
brew "zsh-autosuggestions"            # 히스토리 기반 입력 제안
brew "zsh-fast-syntax-highlighting"   # 명령줄 구문 강조
brew "fzf"                            # Ctrl-R / Ctrl-T 퍼지 검색
brew "direnv"                         # 디렉터리별 환경 변수
brew "zoxide"                         # 자주 가는 디렉터리로 이동 (z)

# --- 모던 CLI (기본 명령 대체) ---
brew "ripgrep"                        # grep -r 대체 (rg)
brew "fd"                             # find 대체, fzf 탐색 백엔드
brew "bat"                            # cat 대체, fzf 미리보기
brew "eza"                            # ls 대체
brew "git-delta"                      # git diff 출력 강조 (delta)

# --- 기본 CLI ---
brew "git"
brew "gh"
brew "node"                           # Node.js 와 npm
brew "uv"                             # Python 버전·패키지 관리
brew "tree"
brew "wget"
brew "yq"
brew "fastfetch"
brew "fortune"

# --- 앱과 폰트 (macOS) ---
if OS.mac?
  cask "ghostty"                      # 터미널 (설정: ghostty/config)
  cask "maccy"                        # 클립보드 히스토리
  cask "font-blex-mono-nerd-font"     # 터미널 기본 폰트
  cask "font-meslo-lg-nerd-font"      # 터미널 보조 / 에디터 폴백
  cask "font-d2coding"                # 에디터 한글 고정폭
  cask "font-pretendard"              # 문서·UI 한글
end
