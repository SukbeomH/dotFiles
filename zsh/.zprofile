# 로그인 셸에서 한 번만 실행된다. PATH 처럼 상속되는 환경만 둔다.

# Homebrew (Apple Silicon → Intel → Linuxbrew 순으로 탐지)
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [[ -x $_brew ]]; then
    eval "$($_brew shellenv)"
    break
  fi
done
unset _brew

# 최소 설치 Linux 는 LANG 이 비어 있어 한글과 아이콘이 깨진다
[[ $OSTYPE == linux* && -z $LANG && -z $LC_ALL ]] && export LANG=C.UTF-8

# 사용자 로컬 바이너리 (uv, pipx 등)
export PATH="$HOME/.local/bin:$PATH"

# 머신 전용 설정 (저장소에 올리지 않음)
[[ -f $HOME/.zprofile.local ]] && source "$HOME/.zprofile.local"
