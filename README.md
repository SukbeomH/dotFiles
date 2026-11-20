# dotFiles

새 컴퓨터를 받거나 포맷한 뒤 터미널 환경과 자주 쓰는 도구를 한 번에 되살리는 구성입니다.
zsh + starship 프롬프트, 플러그인, 폰트, 기본 패키지를 `install.sh` 하나로 적용합니다.
OS 를 감지해 macOS 는 Homebrew, Debian / Ubuntu 는 apt 로 설치합니다.

기본 구성에는 Node.js, npm, uv 와 bat, eza, fd, ripgrep 등의 CLI 가 포함됩니다.
macOS 에서는 Ghostty 와 Maccy 도 기본으로 설치합니다.

## 빠른 시작

macOS:

```zsh
xcode-select --install                 # git 이 없을 때만
git clone --depth 1 https://github.com/SukbeomH/dotFiles.git ~/dotFiles
cd ~/dotFiles
./install.sh
```

Debian / Ubuntu:

```bash
sudo apt-get update && sudo apt-get install -y git
git clone --depth 1 https://github.com/SukbeomH/dotFiles.git ~/dotFiles
cd ~/dotFiles
./install.sh                           # sudo 를 붙이지 않는다. 필요한 곳에서만 sudo 를 쓴다
chsh -s "$(command -v zsh)"            # 기본 셸을 zsh 로
```

설치가 끝나면 두 파일을 채우고 새 터미널을 엽니다.

- `~/.gitconfig.local`: git 이름과 이메일
- `~/.zshrc.local`: 토큰, 사내 인증서 경로, 머신 전용 PATH 와 alias

설정 파일은 이 폴더를 가리키는 심링크이므로, 설치 뒤에 `~/dotFiles` 를 옮기거나 지우면 안 됩니다.

## install.sh

여러 번 실행해도 안전합니다. 이미 있는 설정 파일은 `~/.dotfiles-backup/<시각>/` 으로 옮긴 뒤 심링크합니다.

| 옵션 | macOS | Debian / Ubuntu |
| --- | --- | --- |
| (없음) | Homebrew 설치, `Brewfile` 설치, 설정 심링크 | `apt/packages.txt` 설치, 설정 심링크 |
| `--dev` | 추가 개발 도구 (`Brewfile.dev`) | `apt/packages-dev.txt` |
| `--apps` | 추가 GUI 앱 (`Brewfile.apps`, VS Code 등) | 해당 없음 |
| `--macos` | `macos.sh` 로 키 반복, Finder, Dock 기본값 적용 | 해당 없음 |
| `--fonts` | 해당 없음 (cask 로 항상 설치) | Nerd Font 를 `~/.local/share/fonts` 에 설치 |
| `--all` | 위 항목 중 해당 OS 에 맞는 것 모두 | 왼쪽과 같음 |
| `--no-pkg` | 패키지 설치 없이 심링크만 | 왼쪽과 같음 |
| `--dry-run` | 바꾸지 않고 할 일만 출력 | 왼쪽과 같음 |

처음에는 `./install.sh --dry-run` 으로 무엇이 바뀌는지 확인할 수 있습니다.
그 밖의 Linux 는 Homebrew 가 있으면 Homebrew 로, 없으면 설정 연결만 합니다.

### Debian / Ubuntu 에서 다른 점

| 항목 | 처리 |
| --- | --- |
| 구문 강조 | `fast-syntax-highlighting` 이 apt 에 없어 `zsh-syntax-highlighting` 을 씁니다 |
| `fd`, `bat` | 실행 파일이 `fdfind`, `batcat` 이라 `~/.local/bin/fd`, `~/.local/bin/bat` 으로 연결합니다 |
| `starship` | apt 에 없는 배포판(Debian 12, Ubuntu 24.04)은 공식 스크립트로 `~/.local/bin` 에 설치합니다 |
| `uv` | apt 에 없어 공식 스크립트로 `~/.local/bin` 에 설치합니다 |
| Node.js, npm | 배포판의 apt 저장소 버전을 설치합니다 |
| `eza`, `fastfetch`, `git-delta` | 저장소에 없는 배포판(Debian 12 등)에서는 건너뜁니다. `ls` 와 `git diff` 는 기본 동작, 시작 화면은 생략됩니다 |
| `fzf` | 0.48 미만은 패키지에 든 키 바인딩 스크립트를 읽습니다 |
| 폰트 | 서버에는 필요 없습니다. 폰트는 접속하는 쪽 터미널에 있으면 됩니다 |

확인한 배포판: Debian 13, Debian 12, Ubuntu 24.04.

### 설치가 막힐 수 있는 지점

`install.sh` 는 아래 경우에 멈추지 않고 경고를 남긴 뒤 설정 연결까지 진행합니다. 끝에 "확인이 필요한 항목" 으로 다시 보여 줍니다.

| 상황 | 증상 | 해결 |
| --- | --- | --- |
| 사내 프록시가 HTTPS 인증서를 바꿈 | Linux 에서 starship, uv, 폰트 다운로드 실패 | 사내 CA 를 시스템에 등록하거나 `CURL_CA_BUNDLE=/경로/ca.pem ./install.sh` |
| root 가 아니고 `sudo` 도 없음 | apt 패키지 설치 건너뜀 | 관리자에게 패키지 설치를 요청하거나 `--no-pkg` 로 설정만 연결 |
| `apt-get update` 실패 | 패키지 설치 건너뜀 | 네트워크, 프록시, 저장소 설정 확인 후 다시 실행 |
| apt 패키지 하나가 설치 불가 | 일괄 설치가 취소됨 | 자동으로 패키지별 재시도, 실패한 것만 경고 |
| macOS 에 Xcode Command Line Tools 없음 | 설치 창을 띄우고 종료 | 설치를 마친 뒤 다시 실행 |
| 앱이나 폰트를 이미 수동으로 설치함 | `brew bundle` 이 해당 cask 에서 실패 | 무시하거나 `brew install --cask --force <이름>` |
| zsh 자동완성 경로에 쓰기 권한이 열려 있음 | 해당 경로의 자동완성을 건너뜀 | macOS 기본 설치는 본인 소유의 Homebrew `share` 디렉터리에서 그룹 및 기타 사용자 쓰기 권한을 제거합니다. 문제가 남으면 zsh 에서 `compaudit` 로 경로를 확인하세요 |
| `sudo ./install.sh` 로 실행 | 설정이 root 계정에 연결됨 | sudo 없이 다시 실행 |
| 최소 설치 Linux 에 UTF-8 로케일 없음 | 한글과 아이콘이 깨짐 | `LANG` 이 비어 있으면 `C.UTF-8` 로 자동 설정 |

## 구성

| 경로 | 연결 위치 | 내용 |
| --- | --- | --- |
| `zsh/.zshrc` | `~/.zshrc` | 히스토리, 자동완성, 플러그인, starship |
| `zsh/.zprofile` | `~/.zprofile` | Homebrew 와 `~/.local/bin` PATH |
| `zsh/aliases.zsh` | `.zshrc` 가 읽음 | git, kubectl alias |
| `starship/starship.toml` | `~/.config/starship.toml` | 프롬프트 기본 테마 (아래 "프롬프트 테마" 참고) |
| `starship/frame.toml`, `starship/minimal.toml` | 필요할 때 지정 | 다른 프롬프트 테마 |
| `fastfetch/config.jsonc` | `~/.config/fastfetch/config.jsonc` | 터미널 시작 화면 |
| `git/.gitconfig` | `~/.gitconfig` | 공통 git 설정 (`~/.gitconfig.local` 을 include) |
| `git/ignore` | `~/.config/git/ignore` | 전역 gitignore |
| `ghostty/config` | `~/.config/ghostty/config` | Ghostty 터미널 (폰트, Catppuccin Macchiato 색상, 창) |
| `Brewfile*` | | macOS 패키지 목록 |
| `apt/*.txt` | | Debian / Ubuntu 패키지 목록 |
| `macos.sh` | | macOS 기본 설정 |

### zsh 플러그인

플러그인 매니저 없이 Homebrew 나 apt 로 설치한 것을 `.zshrc` 가 직접 읽습니다.

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

`ls`, `cat` 대체는 터미널에서 직접 쓰는 셸에만 적용됩니다. 스크립트나 AI 에이전트의 셸에서는 원래 명령 그대로입니다.
`grep` 과 `find` 는 옵션과 동작이 달라 alias 로 덮지 않고 `rg`, `fd` 를 따로 씁니다.

명령을 덮지 않고 출력만 바꾸는 확장도 있습니다.

| 대상 | 도구 | 동작 |
| --- | --- | --- |
| `git diff`, `git log -p`, `git show` | `delta` | 구문 강조와 줄 번호. `n` / `N` 으로 파일 사이 이동 |
| `man` | `bat` | man 페이지에 색 표시 |

프롬프트가 느리면 `starship timings` 로 모듈별 시간을 확인합니다.

플러그인이나 도구가 설치돼 있지 않으면 해당 줄만 건너뛰므로, 패키지 설치 전에도 셸은 오류 없이 뜹니다.

### 프롬프트 테마

| 파일 | 모양 | Nerd Font |
| --- | --- | --- |
| `starship/starship.toml` (기본) | 첫째 줄은 선으로 그린 틀, 둘째 줄은 Catppuccin Macchiato powerline | 필요 |
| `starship/frame.toml` | 선으로 틀을 그린 3줄 구성 (a3chron 의 Stellar `ctp-blue` 바탕, MIT) | 불필요 |
| `starship/minimal.toml` | 배경색과 아이콘 없는 단순한 프롬프트 | 불필요 |

기본 테마는 starship 공식 프리셋 `catppuccin-powerline` 의 색 순서를 따릅니다.

- 첫째 줄(시스템, 배경 없음): 사용자@호스트, 로컬 IP, 셸, CPU, RAM, DISK, 배터리, 시각
- 둘째 줄(작업): OS·디렉터리, git, 언어 런타임, Kubernetes·Docker·direnv, 2초 넘은 명령의 실행 시간
- 셋째 줄: 입력

CPU 는 1분 평균 부하를 코어 수로 나눈 비율이고, DISK 는 루트 볼륨 사용률입니다. 이 둘은 프롬프트마다 명령을 실행합니다(각 25ms 안팎, 병렬).
첫째 줄에 로컬 IP 가 항상 보이므로, 화면을 공유할 때 가리려면 `starship.toml` 의 `[localip]` 를 `disabled = true` 로 바꿉니다.

바꾸는 방법:

- 테마 전환: `~/.zshrc.local` 에 `export STARSHIP_CONFIG=~/dotFiles/starship/frame.toml` 을 넣습니다.
- 색 조합: 각 파일의 `palette` 를 `catppuccin_mocha`, `catppuccin_frappe`, `catppuccin_latte` 로 바꿉니다. Ghostty 는 `ghostty/config` 의 `theme` 을 같은 이름으로 맞춥니다.
- 다른 공식 프리셋 미리 보기: `starship preset --list` 로 목록을 보고, `starship preset pastel-powerline -o /tmp/p.toml` 로 받은 뒤 `STARSHIP_CONFIG=/tmp/p.toml zsh` 로 띄워 봅니다.

### 폰트

폰트 파일은 저장소에 두지 않습니다. macOS 는 `Brewfile` 의 cask 로, Linux 데스크톱은 `./install.sh --fonts` 로 설치합니다(BlexMono, Meslo Nerd Font).

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

패키지를 추가할 때는 해당 `Brewfile` 과 `apt/packages.txt` 에 한 줄을 넣고 `./install.sh` 를 다시 실행합니다.
지금 머신에 설치된 것과 비교하려면 다음을 씁니다.

```zsh
brew bundle check --file=Brewfile --verbose
```
