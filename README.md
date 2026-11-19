# dotFiles

새 맥을 받거나 포맷한 뒤 터미널 환경을 한 번에 되살리는 최소 구성입니다.
zsh + starship 프롬프트, 플러그인, 폰트, 기본 패키지를 `install.sh` 하나로 적용합니다.

## 빠른 시작

```zsh
xcode-select --install                 # git 이 없을 때만
git clone --depth 1 https://github.com/SukbeomH/dotFiles.git ~/dotFiles
cd ~/dotFiles
./install.sh
```

`--depth 1` 을 붙이면 예전 커밋에 들어 있던 폰트 바이너리(약 1.3GB)를 받지 않습니다.

설치가 끝나면 두 파일을 채우고 새 터미널을 엽니다.

- `~/.gitconfig.local`: git 이름과 이메일
- `~/.zshrc.local`: 토큰, 사내 인증서 경로, 머신 전용 PATH 와 alias

## install.sh

여러 번 실행해도 안전합니다. 이미 있는 설정 파일은 `~/.dotfiles-backup/<시각>/` 으로 옮긴 뒤 심링크합니다.

| 옵션 | 하는 일 |
| --- | --- |
| (없음) | Homebrew 설치, `Brewfile` 설치, 설정 심링크 |
| `--dev` | `Brewfile.dev` (언어 런타임, Kubernetes 도구) 추가 설치 |
| `--apps` | `Brewfile.apps` (Ghostty, VS Code 등 GUI 앱) 추가 설치 |
| `--macos` | `macos.sh` 로 키 반복, Finder, Dock 기본값 적용 |
| `--all` | 위 세 가지 모두 |
| `--no-brew` | 패키지 설치 없이 심링크만 |
| `--dry-run` | 바꾸지 않고 할 일만 출력 |

처음에는 `./install.sh --dry-run` 으로 무엇이 바뀌는지 확인할 수 있습니다.

## 구성

| 경로 | 연결 위치 | 내용 |
| --- | --- | --- |
| `zsh/.zshrc` | `~/.zshrc` | 히스토리, 자동완성, 플러그인, starship |
| `zsh/.zprofile` | `~/.zprofile` | Homebrew 와 `~/.local/bin` PATH |
| `zsh/aliases.zsh` | `.zshrc` 가 읽음 | git, kubectl alias |
| `starship/starship.toml` | `~/.config/starship.toml` | 프롬프트 |
| `fastfetch/config.jsonc` | `~/.config/fastfetch/config.jsonc` | 터미널 시작 화면 |
| `git/.gitconfig` | `~/.gitconfig` | 공통 git 설정 (`~/.gitconfig.local` 을 include) |
| `git/ignore` | `~/.config/git/ignore` | 전역 gitignore |
| `ghostty/config` | `~/.config/ghostty/config` | Ghostty 터미널 (폰트, 색상, 창) || `Brewfile*` | | 패키지 목록 |
| `macos.sh` | | macOS 기본 설정 |

### zsh 플러그인

플러그인 매니저 없이 Homebrew 로 설치한 것을 `.zshrc` 가 직접 읽습니다.

- `zsh-autosuggestions`: 히스토리를 바탕으로 입력을 흐리게 제안합니다. `→` 로 수락합니다.
- `zsh-fast-syntax-highlighting`: 명령줄 구문 강조
- `fzf`: `Ctrl-R` 히스토리 검색, `Ctrl-T` 파일 검색, `Alt-C` 디렉터리 이동
- `direnv`: 디렉터리별 `.envrc` 자동 로드. 처음이나 수정 뒤에는 `direnv allow .` 로 승인합니다.
- `zoxide`: `z 일부이름` 으로 자주 가는 디렉터리 이동

### 모던 CLI

설치돼 있을 때만 기본 명령을 대체합니다.

| 도구 | 대체 | 설정 |
| --- | --- | --- |
| `ripgrep` (`rg`) | `grep -r` | `zsh/ripgreprc`: smart-case, 숨김 파일 포함, `.git` 제외 |
| `fd` | `find` | fzf 의 `Ctrl-T`, `Alt-C` 탐색 백엔드 |
| `bat` | `cat` | `cat` alias(구문 강조만, 테두리 없음), fzf `Ctrl-T` 미리보기 |
| `eza` | `ls` | `ls`, `ll`, `lt`(트리) alias. 아이콘은 터미널 출력에만 붙음 |

원래 명령이 필요하면 `\cat`, `\ls` 처럼 역슬래시를 붙입니다.

프롬프트가 느리면 `starship timings` 로 모듈별 시간을 확인합니다.

플러그인이나 도구가 설치돼 있지 않으면 해당 줄만 건너뛰므로, 패키지 설치 전에도 셸은 오류 없이 뜹니다.

### 폰트

폰트 파일은 저장소에 두지 않고 `Brewfile` 의 cask 로 설치합니다.

| cask | 쓰는 곳 |
| --- | --- |
| `font-blex-mono-nerd-font` | 터미널 기본 폰트 (starship 아이콘 포함) |
| `font-meslo-lg-nerd-font` | 터미널 보조, 에디터 폴백 |
| `font-d2coding` | 에디터 한글 고정폭 |
| `font-pretendard` | 문서와 UI 한글 |

cask 가 없는 [Monoplex KR](https://github.com/y-kim/monoplex) 은 필요할 때 릴리스에서 직접 내려받습니다.

## 머신 전용 설정과 시크릿

이 저장소는 공개 저장소입니다. 토큰, 사내 주소, 인증서 경로는 저장소 파일에 쓰지 말고 `~/.zshrc.local` 에 둡니다.
`*.local` 은 `.gitignore` 에 들어 있고, 예시는 `zsh/zshrc.local.example` 에 있습니다.

터미널 시작 화면(fastfetch, fortune)을 끄려면 `~/.zshrc.local` 에 `DOTFILES_NO_GREETING=1` 을 넣습니다.

## 설정 변경과 패키지 추가

설정 파일은 심링크라서 `~/.zshrc` 를 고치면 곧바로 이 저장소의 변경이 됩니다. 커밋하고 푸시하면 끝입니다.

패키지를 추가할 때는 해당 `Brewfile` 에 한 줄을 넣고 `./install.sh` 를 다시 실행합니다.
지금 머신에 설치된 것과 비교하려면 다음을 씁니다.

```zsh
brew bundle check --file=Brewfile --verbose
```
