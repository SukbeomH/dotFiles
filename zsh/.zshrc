# ==============================================================================
# zsh 최소 구성: starship + autosuggestions + fast-syntax-highlighting + fzf
# 모든 외부 도구는 설치돼 있을 때만 로드하므로, 도구가 없어도 오류 없이 뜬다.
# 머신 전용 설정과 시크릿은 ~/.zshrc.local 에 둔다 (저장소에 올리지 않음).
# ==============================================================================

# 이 파일(심링크)의 실제 위치 = dotFiles/zsh
DOTFILES_ZSH="${${(%):-%x}:A:h}"

# 비로그인 셸에서도 Homebrew 를 쓸 수 있게 한다 (.zprofile 이 이미 했다면 건너뜀)
if [[ -z $HOMEBREW_PREFIX ]]; then
  for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [[ -x $_brew ]] && { eval "$($_brew shellenv)"; break; }
  done
  unset _brew
fi

# 최소 설치 Linux 는 LANG 이 비어 있어 한글과 아이콘이 깨진다
[[ $OSTYPE == linux* && -z $LANG && -z $LC_ALL ]] && export LANG=C.UTF-8

# Linux 터미널은 보통 비로그인 셸로 열려 .zprofile 을 읽지 않으므로 여기서도 넣는다.
# /usr/games 는 Debian 계열에서 fortune 이 설치되는 위치다.
typeset -U path fpath
path=("$HOME/.local/bin" $path)
[[ -d /usr/games ]] && path+=(/usr/games)

# ------------------------------------------------------------------------------
# 1. History
# ------------------------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # 세션 간 히스토리 공유 (즉시 기록 포함)
setopt HIST_IGNORE_ALL_DUPS   # 중복 명령은 최신 것만 유지
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE      # 공백으로 시작하는 명령은 기록하지 않음

# ------------------------------------------------------------------------------
# 2. 기본 옵션
# ------------------------------------------------------------------------------
setopt AUTO_CD
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS

# ------------------------------------------------------------------------------
# 3. Completion
# ------------------------------------------------------------------------------
[[ -n $HOMEBREW_PREFIX ]] && fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
[[ -d $HOME/.docker/completions ]] && fpath=("$HOME/.docker/completions" $fpath)
[[ -d $HOME/.zsh/completion ]] && fpath=("$HOME/.zsh/completion" $fpath)

autoload -Uz compinit
# 권한이 안전하지 않은 자동완성 경로는 제외하고 나머지는 초기화한다.
compinit -i

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:descriptions' format '%B%d%b'

# ------------------------------------------------------------------------------
# 4. Key bindings
# ------------------------------------------------------------------------------
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ------------------------------------------------------------------------------
# 5. Aliases
# ------------------------------------------------------------------------------
[[ -f $DOTFILES_ZSH/aliases.zsh ]] && source "$DOTFILES_ZSH/aliases.zsh"

# ------------------------------------------------------------------------------
# 6. 도구 초기화 (설치된 것만)
# ------------------------------------------------------------------------------
# fzf: Ctrl-R 히스토리, Ctrl-T 파일, Alt-C 디렉터리
if (( $+commands[fzf] )); then
  # fd 가 있으면 탐색 백엔드로 쓴다 (.gitignore 를 따르고 더 빠름)
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
  fi
  # bat 이 있으면 Ctrl-T 에서 파일 내용을 미리 본다
  (( $+commands[bat] )) && export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
  if fzf --zsh &>/dev/null; then
    source <(fzf --zsh)
  else
    # fzf 0.48 미만(Debian 12 등)은 --zsh 가 없어 패키지에 든 스크립트를 읽는다
    for _f in /usr/share/doc/fzf/examples/{key-bindings,completion}.zsh; do
      [[ -r $_f ]] && source "$_f"
    done
    unset _f
  fi
fi

# git diff / log -p / show 를 delta 로 본다 (구문 강조, 줄 번호).
# gitconfig 의 core.pager 로 두면 delta 가 없는 머신에서 git 이 깨지므로 환경 변수로 건다.
# 세부 옵션은 git/.gitconfig 의 [delta] 에 있다.
(( $+commands[delta] )) && export GIT_PAGER=delta

# man 페이지를 bat 으로 색칠해서 본다
if (( $+commands[bat] && $+commands[col] )); then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT=-c
fi

# ripgrep 기본 옵션
[[ -f $DOTFILES_ZSH/ripgreprc ]] && export RIPGREP_CONFIG_PATH="$DOTFILES_ZSH/ripgreprc"

if (( $+commands[direnv] )); then
  export DIRENV_LOG_FORMAT=$'\033[2m  direnv │ %s\033[0m'
  eval "$(direnv hook zsh)"
fi

# 명령이 출력하는 셸 스크립트(자동완성 등)를 캐시해 두고 읽는다.
# 매번 생성하면 도구당 0.1~0.6초가 걸린다. 바이너리가 갱신되면 캐시를 다시 만든다.
#   _cached_source <명령> [인자...]      예: _cached_source kubectl completion zsh
# ~/.zshrc.local 에서도 쓸 수 있다. 캐시를 지우려면: rm -r ~/.cache/zsh
_cached_source() {
  local bin=${commands[$1]}
  [[ -n $bin ]] || return 0
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/$1.zsh"
  if [[ ! -s $cache || $bin -nt $cache ]]; then
    mkdir -p "${cache:h}"
    "$@" >| "$cache" 2>/dev/null || { rm -f "$cache"; return 0; }
  fi
  source "$cache"
}

# 자동완성 스크립트를 내장한 CLI 들
_cached_source kubectl completion zsh
_cached_source helm completion zsh
_cached_source gh completion -s zsh
_cached_source uv generate-shell-completion zsh

# ------------------------------------------------------------------------------
# 7. 머신 전용 설정 (시크릿, 사내 인증서, 프록시, 개별 도구 PATH 등)
# ------------------------------------------------------------------------------
[[ -f $HOME/.zshrc.local ]] && source "$HOME/.zshrc.local"

# ------------------------------------------------------------------------------
# 8. 플러그인 (Homebrew 또는 apt 로 설치, 로드 순서 중요)
# ------------------------------------------------------------------------------
# 찾으면 읽고 0, 없으면 1 을 돌려준다
_plugin() {
  local dir
  for dir in ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share} /usr/share /usr/share/zsh/plugins; do
    [[ -r $dir/$1 ]] && { source "$dir/$1"; return 0; }
  done
  return 1
}
_plugin zsh-autosuggestions/zsh-autosuggestions.zsh
# 구문 강조는 다른 위젯이 모두 등록된 뒤 마지막에 로드한다.
# fast-syntax-highlighting 이 없으면(apt) zsh-syntax-highlighting 을 쓴다.
_plugin zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh \
  || _plugin zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
unfunction _plugin

# ------------------------------------------------------------------------------
# 9. Prompt
# ------------------------------------------------------------------------------
# zoxide: `z 일부이름` 으로 자주 가는 디렉터리 이동, `zi` 로 fzf 선택.
# cd 훅을 거는 도구라 뒤쪽, starship 바로 앞에 둔다.
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
# 부팅 직후처럼 네트워크가 없거나 명령이 느릴 때 starship 이 프롬프트 위에 [WARN] 을
# 쏟아내지 않게 한다. 해당 항목은 그 프롬프트에서만 빠진다.
# 설정을 고치다 원인을 봐야 하면: STARSHIP_LOG=warn starship prompt
export STARSHIP_LOG=${STARSHIP_LOG:-error}
(( $+commands[starship] )) && eval "$(starship init zsh)"

# ------------------------------------------------------------------------------
# 10. 터미널 시작 인사 (DOTFILES_NO_GREETING=1 로 끌 수 있음)
# ------------------------------------------------------------------------------
# 로그인 셸(macOS 터미널, SSH)이거나 최상위 셸(Linux 터미널)일 때만 출력한다
if [[ -z $DOTFILES_NO_GREETING ]] && [[ -o login || $SHLVL -le 1 ]]; then
  (( $+commands[fastfetch] )) && fastfetch
  if (( $+commands[fortune] )); then
    # fastfetch 와 fortune 사이에 빈 줄 2개
    (( $+commands[fastfetch] )) && print '\n'
    fortune
    echo
  fi
fi
