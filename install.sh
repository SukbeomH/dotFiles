#!/usr/bin/env bash
# 새 환경 부트스트랩. 여러 번 실행해도 안전하다(멱등).
# OS 를 감지해 macOS 는 Homebrew, Debian/Ubuntu 는 apt 로 패키지를 설치한다.
#   ./install.sh                 코어 패키지 설치 + 설정 심링크
#   ./install.sh --dev --apps    선택 패키지까지 설치
#   ./install.sh --dry-run       무엇을 할지 출력만
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
OS="$(uname -s)"

WARNINGS=""
DRY_RUN=0 DO_PKG=1 DO_DEV=0 DO_APPS=0 DO_MACOS=0 DO_FONTS=0

usage() {
  cat <<'EOF'
사용법: ./install.sh [옵션]

  --dev        추가 개발 도구 설치 (Brewfile.dev / apt/packages-dev.txt)
  --apps       추가 macOS GUI 앱 설치 (Brewfile.apps)
  --macos      macos.sh (macOS 기본 설정) 적용
  --fonts      Linux: Nerd Font 를 ~/.local/share/fonts 에 설치
               (macOS 는 Brewfile 의 cask 로 항상 설치)
  --all        위 네 가지 모두 (해당 OS 에 맞는 것만 적용)
  --no-pkg     패키지 설치를 건너뛰고 심링크만 (--no-brew 도 같은 뜻)
  --dry-run    실제로 바꾸지 않고 할 일만 출력
  -h, --help   도움말
EOF
}

for arg in "$@"; do
  case "$arg" in
    --dev) DO_DEV=1 ;;
    --apps) DO_APPS=1 ;;
    --macos) DO_MACOS=1 ;;
    --fonts) DO_FONTS=1 ;;
    --all) DO_DEV=1 DO_APPS=1 DO_MACOS=1 DO_FONTS=1 ;;
    --no-pkg|--no-brew) DO_PKG=0 ;;
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
warn() {
  note "경고: $*"
  WARNINGS="$WARNINGS
    - $*"
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

is_debian_like() {
  [[ -r /etc/os-release ]] || return 1
  command -v apt-get >/dev/null 2>&1 || return 1
  grep -qiE '^(ID|ID_LIKE)=.*(debian|ubuntu)' /etc/os-release
}

# 패키지 관리자 결정: macOS → brew, Debian 계열 → apt, 그 외 Linux → brew 가 있으면 brew
detect_pkg_manager() {
  case "$OS" in
    Darwin) echo brew ;;
    Linux)
      if is_debian_like; then
        echo apt
      elif [[ -n "$(find_brew || true)" ]]; then
        echo brew
      else
        echo none
      fi
      ;;
    *) echo none ;;
  esac
}

# ------------------------------------------------------------------------------
# 패키지: Homebrew (macOS, Linuxbrew)
# ------------------------------------------------------------------------------
install_with_brew() {
  if [[ "$OS" == "Darwin" ]] && ! xcode-select -p >/dev/null 2>&1; then
    info "Xcode Command Line Tools 가 필요합니다"
    run xcode-select --install
    echo "설치 창에서 설치를 마친 뒤 이 스크립트를 다시 실행하세요."
    (( DRY_RUN )) || exit 1
  fi

  local brew_bin
  brew_bin="$(find_brew || true)"
  if [[ -z "$brew_bin" ]]; then
    info "Homebrew 설치"
    if (( DRY_RUN )); then
      note "[dry-run] Homebrew 공식 설치 스크립트 실행"
    else
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      brew_bin="$(find_brew)"
    fi
  fi
  [[ -n "$brew_bin" ]] && eval "$("$brew_bin" shellenv)"

  local bundles="Brewfile" bundle
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
    run brew bundle --file="$DOTFILES/$bundle" || warn "$bundle 의 일부 패키지 설치 실패 (위 brew 출력 확인)"
  done
}

# ------------------------------------------------------------------------------
# 패키지: apt (Debian, Ubuntu)
# ------------------------------------------------------------------------------
# 목록 파일에서 주석과 빈 줄을 뺀 패키지 이름만 출력한다
read_list() {
  awk '{ sub(/#.*/, "") } NF { print $1 }' "$1"
}

install_with_apt() {
  local sudo_cmd=""
  if [[ "$(id -u)" -ne 0 ]]; then
    if ! command -v sudo >/dev/null 2>&1; then
      warn "root 가 아니고 sudo 도 없어 apt 패키지 설치를 건너뜁니다"
      return 0
    fi
    sudo_cmd="sudo"
  fi

  info "apt 패키지 목록 갱신"
  if ! run $sudo_cmd apt-get update -qq; then
    warn "apt-get update 실패 (네트워크·프록시·저장소 설정 확인). 패키지 설치를 건너뜁니다"
    return 0
  fi

  local lists="apt/packages.txt" list pkg policy
  (( DO_DEV )) && lists="$lists apt/packages-dev.txt"

  # 배포판 버전에 따라 없는 패키지가 있으므로, 설치 가능한 것만 골라 설치한다
  local available=() missing=() failed=()
  local has_candidate='Candidate: [^(]'   # 설치 후보가 없으면 "Candidate: (none)"
  for list in $lists; do
    for pkg in $(read_list "$DOTFILES/$list"); do
      policy="$(apt-cache policy "$pkg" 2>/dev/null || true)"
      if [[ "$policy" =~ $has_candidate ]]; then
        available+=("$pkg")
      else
        missing+=("$pkg")
      fi
    done
  done

  local apt_install="env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends"
  if (( ${#available[@]} )); then
    info "apt install: ${available[*]}"
    # 한 번에 설치하다 실패하면(패키지 하나의 의존성 문제로 전체가 취소됨) 하나씩 다시 시도한다
    if ! run $sudo_cmd $apt_install "${available[@]}"; then
      note "일괄 설치 실패. 패키지별로 다시 시도합니다"
      for pkg in "${available[@]}"; do
        $sudo_cmd $apt_install "$pkg" >/dev/null 2>&1 || failed+=("$pkg")
      done
    fi
  fi
  if (( ${#missing[@]} )); then
    note "이 배포판의 apt 저장소에 없어 건너뜀: ${missing[*]}"
  fi
  if (( ${#failed[@]} )); then
    warn "apt 설치 실패: ${failed[*]}"
  fi

  apt_post_install
}

# apt 로 해결되지 않는 부분을 사용자 홈(~/.local/bin) 안에서 보완한다
apt_post_install() {
  local bin_dir="$HOME/.local/bin"
  run mkdir -p "$bin_dir"

  if ! command -v curl >/dev/null 2>&1; then
    warn "curl 이 없어 starship·uv 설치를 건너뜁니다 (apt 설치가 실패했는지 확인)"
    return 0
  fi

  # Debian 은 이름 충돌 때문에 fd → fdfind, bat → batcat 으로 설치한다
  local pair real short
  for pair in fdfind:fd batcat:bat; do
    real="${pair%%:*}" short="${pair##*:}"
    if command -v "$real" >/dev/null 2>&1 && ! command -v "$short" >/dev/null 2>&1; then
      run ln -sf "$(command -v "$real")" "$bin_dir/$short"
      note "링크  $bin_dir/$short → $real"
    fi
  done

  # 아래 두 설치는 HTTPS 다운로드라, 사내 프록시가 인증서를 바꾸는 환경에서는
  # 사내 CA 를 시스템에 등록하기 전까지 실패할 수 있다.
  # starship: apt 에 없는 배포판(Debian 12, Ubuntu 24.04 이하)은 공식 설치 스크립트 사용
  if ! command -v starship >/dev/null 2>&1 && [[ ! -x "$bin_dir/starship" ]]; then
    info "starship 설치 (공식 스크립트 → $bin_dir)"
    if (( DRY_RUN )); then
      note "[dry-run] curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b $bin_dir"
    elif ! curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$bin_dir" >/dev/null; then
      warn "starship 설치 실패. 프롬프트는 zsh 기본값으로 뜹니다"
    fi
  fi

  # uv: apt 에 없어 공식 설치 스크립트 사용 (셸 설정 파일은 건드리지 않게 한다)
  if ! command -v uv >/dev/null 2>&1 && [[ ! -x "$bin_dir/uv" ]]; then
    info "uv 설치 (공식 스크립트 → $bin_dir)"
    if (( DRY_RUN )); then
      note "[dry-run] curl -LsSf https://astral.sh/uv/install.sh | sh"
    elif ! curl -LsSf https://astral.sh/uv/install.sh \
        | env UV_NO_MODIFY_PATH=1 INSTALLER_NO_MODIFY_PATH=1 UV_INSTALL_DIR="$bin_dir" sh >/dev/null 2>&1; then
      warn "uv 설치 실패"
    fi
  fi
}

# Linux 데스크톱용: Nerd Font 를 사용자 폰트 폴더에 설치한다.
# SSH 로만 쓰는 서버에는 필요 없다(폰트는 접속하는 쪽 터미널에 있으면 된다).
install_fonts_linux() {
  local font_dir="$HOME/.local/share/fonts/NerdFonts" name
  info "Nerd Font 설치 → $font_dir"
  if ! command -v curl >/dev/null 2>&1 || ! command -v xz >/dev/null 2>&1; then
    warn "폰트 설치에는 curl 과 xz 가 필요합니다 (apt install curl xz-utils)"
    return 0
  fi
  run mkdir -p "$font_dir"
  for name in IBMPlexMono Meslo; do
    if (( DRY_RUN )); then
      note "[dry-run] $name.tar.xz 내려받아 $font_dir 에 풀기"
    elif curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$name.tar.xz" \
        | tar -xJ -C "$font_dir" --wildcards '*.ttf' 2>/dev/null; then
      note "설치  $name Nerd Font"
    else
      warn "$name Nerd Font 내려받기 실패"
    fi
  done
  if command -v fc-cache >/dev/null 2>&1; then
    run fc-cache -f "$font_dir"
  fi
}

# ------------------------------------------------------------------------------
# 1. 패키지
# ------------------------------------------------------------------------------
PKG_MANAGER="$(detect_pkg_manager)"
info "환경: $OS / 패키지 관리자: $PKG_MANAGER"

# sudo 로 실행하면 HOME 이 root 로 바뀌어 설정이 root 계정에 걸린다
if [[ -n "${SUDO_USER:-}" && "$(id -u)" -eq 0 ]]; then
  warn "sudo 로 실행 중입니다. 설정이 $HOME 에 연결됩니다. 본인 계정에 적용하려면 sudo 없이 실행하세요"
fi

if (( DO_PKG )); then
  case "$PKG_MANAGER" in
    brew) install_with_brew ;;
    apt) install_with_apt ;;
    *) warn "지원하는 패키지 관리자를 찾지 못해 패키지 설치를 건너뜁니다 (설정 연결만 진행)" ;;
  esac
else
  info "패키지 설치 건너뜀 (--no-pkg)"
fi

if (( DO_FONTS )) && [[ "$OS" == "Linux" ]]; then
  install_fonts_linux
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
  if [[ "$OS" == "Darwin" ]]; then
    info "macOS 기본 설정"
    run bash "$DOTFILES/macos.sh"
  else
    note "--macos 는 macOS 전용이라 건너뜁니다"
  fi
fi

# ------------------------------------------------------------------------------
# 4. 마무리
# ------------------------------------------------------------------------------
if command -v zsh >/dev/null 2>&1; then
  case "${SHELL:-}" in
    */zsh) ;;
    *) note "기본 셸이 zsh 가 아닙니다. 바꾸려면: chsh -s \"\$(command -v zsh)\"" ;;
  esac
else
  warn "zsh 가 설치돼 있지 않습니다"
fi

info "완료"
(( DRY_RUN )) && note "dry-run 이라 실제로 바뀐 것은 없습니다"
if [[ -n "$WARNINGS" ]]; then
  printf '    확인이 필요한 항목:%s\n' "$WARNINGS"
fi
note "~/.gitconfig.local 에 이름·이메일, ~/.zshrc.local 에 머신 전용 값을 채우세요"
note "새 터미널을 열거나 'exec zsh -l' 로 적용합니다"
