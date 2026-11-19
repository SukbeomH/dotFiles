# Git
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gc='git commit -v'
alias gcb='git checkout -b'
alias gcm='git checkout main'
alias gcmsg='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gl='git pull'
alias glog='git log --oneline --decorate --graph'
alias gp='git push'
alias grb='git rebase'
alias gst='git status'
alias gsw='git switch'
alias gswc='git switch -c'

# Kubectl
alias k='kubectl'
alias ka='kubectl apply'
alias kaf='kubectl apply -f'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias keti='kubectl exec -ti'
alias kg='kubectl get'
alias kga='kubectl get all'
alias kgd='kubectl get deploy'
alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgs='kubectl get svc'
alias kgss='kubectl get statefulset'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kns='kubectl config set-context --current --namespace'
alias kpf='kubectl port-forward'
alias krm='kubectl delete'
alias krmf='kubectl delete -f'
alias ksd='kubectl scale deploy'
alias ktop='kubectl top'
alias ktopn='kubectl top nodes'
alias ktopp='kubectl top pods'
alias kx='kubectl config use-context'

# 모던 CLI 로 기본 명령 대체 (설치돼 있을 때만).
# 사람이 터미널에서 직접 쓰는 셸에만 적용한다. 터미널이 붙지 않은 셸(스크립트 실행기,
# AI 코딩 에이전트가 떠 가는 셸 설정 등)까지 alias 가 들어가면, 기본 명령의 출력을
# 기대하는 쪽이 조용히 깨진다. grep→rg, find→fd 는 옵션과 동작이 달라 대체하지 않는다.
if [[ -t 0 && -t 1 ]] && (( $+commands[eza] )); then
  __eza_ls() {
    # 아이콘은 터미널에 직접 출력할 때만 붙인다 (파이프 출력에는 섞이지 않게).
    # eza 0.23 의 --icons=auto 는 터미널에서도 아이콘을 내지 않아 직접 판별한다.
    local icons=never
    [[ -t 1 ]] && icons=always
    if [[ -t 0 ]]; then
      command eza --icons=$icons "$@"
    else
      # stdin 이 파이프면 eza 가 파일 이름을 stdin 에서 읽으려 해 빈 출력이 된다
      command eza --icons=$icons "$@" </dev/tty
    fi
  }
  alias ls='__eza_ls'
  alias ll='__eza_ls -la --git'
  alias lt='__eza_ls --tree --level=2'
else
  # GNU ls(Linux)와 BSD ls(macOS)는 색상 옵션이 다르다
  if ls --color=auto -d . &>/dev/null; then
    alias ls='ls --color=auto'
  else
    alias ls='ls -G'
  fi
  alias ll='ls -lah'
fi
# cat 자리에서는 테두리·줄 번호 없이 구문 강조만 한다. 전체 장식은 bat 을 직접 쓴다.
# 파이프로 넘길 때는 bat 이 알아서 색 없이 원문만 낸다.
[[ -t 0 && -t 1 ]] && (( $+commands[bat] )) && alias cat='bat --paging=never --style=plain'

# 기타
alias reload='exec zsh -l'
