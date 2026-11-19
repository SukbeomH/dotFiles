#!/usr/bin/env bash
# 새 환경 부트스트랩. 여러 번 실행해도 안전하다(멱등).
#   ./install.sh                 코어 패키지 설치 + 설정 심링크
#   ./install.sh --dev --apps    선택 Brewfile 까지 설치
#   ./install.sh --dry-run       무엇을 할지 출력만
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
OS="$(uname -s)"

FAILED_BUNDLES=""
DRY_RUN=0 DO_BREW=1 DO_DEV=0 DO_APPS=0 DO_MACOS=0

usage() {
  cat <<'EOF'
사용법: ./install.sh [옵션]

  --dev        Brewfile.dev (개발 도구) 도 설치
  --apps       Brewfile.apps (macOS GUI 앱) 도 설치
  --macos      macos.sh (macOS 기본 설정) 적용
  --all        위 세 가지 모두
  --no-brew    Homebrew 설치와 brew bundle 을 건너뛰고 심링크만
  --dry-run    실제로 바꾸지 않고 할 일만 출력
  -h, --help   도움말
EOF
}

for arg in "$@"; do
  case "$arg" in
    --dev) DO_DEV=1 ;;
    --apps) DO_APPS=1 ;;
    --macos) DO_MACOS=1 ;;
    --all) DO_DEV=1 DO_APPS=1 DO_MACOS=1 ;;
    --no-brew) DO_BREW=0 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "알 수 없는 옵션: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
# 출력에서는 홈 경로를 ~ 로 줄여 보여 준다
note() {
  local msg="$*"
  printf '    %s\n' "${msg//"$HOME"/"~"}"
}
run() {
  if (( DRY_RUN )); then
    note "[dry-run] $*"
  else
    "$@"
  fi
}

# src(저장소 기준 상대 경로) 를 dest 로 심링크한다. 기존 파일은 백업 폴더로 옮긴다.
link() {
  local src="$DOTFILES/$1" dest="$2"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    note "유지  $dest"
    return
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    local backup="$BACKUP_DIR/${dest#"$HOME"/}"
    run mkdir -p "$(dirname "$backup")"
    run mv "$dest" "$backup"
    note "백업  $dest → $backup"
  fi
  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
  note "링크  $dest → $src"
}

# 예시 파일을 처음 한 번만 복사한다. 이미 있으면 건드리지 않는다.
seed() {
  local src="$DOTFILES/$1" dest="$2"
  if [[ -e "$dest" ]]; then
    note "유지  $dest"
  else
    run cp "$src" "$dest"
    note "생성  $dest (내용을 채워 주세요)"
  fi
}

find_brew() {
  local candidate
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    if [[ -x "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done
  command -v brew 2>/dev/null
}

# ------------------------------------------------------------------------------
# 1. 패키지
# ------------------------------------------------------------------------------
if (( DO_BREW )); then
  if [[ "$OS" == "Darwin" ]] && ! xcode-select -p >/dev/null 2>&1; then
    info "Xcode Command Line Tools 가 필요합니다"
    run xcode-select --install
    echo "설치 창에서 설치를 마친 뒤 이 스크립트를 다시 실행하세요."
    (( DRY_RUN )) || exit 1
  fi

  BREW="$(find_brew || true)"
  if [[ -z "$BREW" ]]; then
    info "Homebrew 설치"
    if (( DRY_RUN )); then
      note "[dry-run] Homebrew 공식 설치 스크립트 실행"
    else
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      BREW="$(find_brew)"
    fi
  fi
  [[ -n "$BREW" ]] && eval "$("$BREW" shellenv)"

  bundles="Brewfile"
  (( DO_DEV )) && bundles="$bundles Brewfile.dev"
  if (( DO_APPS )); then
    if [[ "$OS" == "Darwin" ]]; then
      bundles="$bundles Brewfile.apps"
    else
      note "Brewfile.apps 는 macOS 전용이라 건너뜁니다"
    fi
  fi
  for bundle in $bundles; do
    info "brew bundle: $bundle"
    # 일부 패키지가 실패해도(이미 수동 설치된 앱 등) 설정 연결까지는 진행한다
    run brew bundle --file="$DOTFILES/$bundle" || FAILED_BUNDLES="$FAILED_BUNDLES $bundle"
  done
else
  info "패키지 설치 건너뜀 (--no-brew)"
fi

# ------------------------------------------------------------------------------
# 2. 설정 심링크
# ------------------------------------------------------------------------------
info "설정 연결"

# 기존 ~/.gitconfig 가 일반 파일이면 개인 정보(이름·이메일)를 잃지 않도록
# ~/.gitconfig.local 로 넘긴다. 공통 설정이 그 파일을 include 한다.
if [[ -f "$HOME/.gitconfig" && ! -L "$HOME/.gitconfig" && ! -e "$HOME/.gitconfig.local" ]]; then
  run mv "$HOME/.gitconfig" "$HOME/.gitconfig.local"
  note "이전  ~/.gitconfig → ~/.gitconfig.local"
fi

link zsh/.zshrc               "$HOME/.zshrc"
link zsh/.zprofile            "$HOME/.zprofile"
link starship/starship.toml   "$HOME/.config/starship.toml"
link fastfetch/config.jsonc   "$HOME/.config/fastfetch/config.jsonc"
link git/.gitconfig           "$HOME/.gitconfig"
link git/ignore               "$HOME/.config/git/ignore"
link ghostty/config           "$HOME/.config/ghostty/config"

seed zsh/zshrc.local.example      "$HOME/.zshrc.local"
seed git/gitconfig.local.example  "$HOME/.gitconfig.local"

# ------------------------------------------------------------------------------
# 3. 선택 항목 (macOS)
# ------------------------------------------------------------------------------
if (( DO_MACOS )); then
  info "macOS 기본 설정"
  run bash "$DOTFILES/macos.sh"
fi

# ------------------------------------------------------------------------------
# 4. 마무리
# ------------------------------------------------------------------------------
case "${SHELL:-}" in
  */zsh) ;;
  *) note "기본 셸이 zsh 가 아닙니다. 바꾸려면: chsh -s \"\$(command -v zsh)\"" ;;
esac

info "완료"
(( DRY_RUN )) && note "dry-run 이라 실제로 바뀐 것은 없습니다"
[[ -n "$FAILED_BUNDLES" ]] && note "일부 패키지 설치 실패:$FAILED_BUNDLES (위 brew 출력을 확인하세요)"
note "~/.gitconfig.local 에 이름·이메일, ~/.zshrc.local 에 머신 전용 값을 채우세요"
note "새 터미널을 열거나 'exec zsh -l' 로 적용합니다"
