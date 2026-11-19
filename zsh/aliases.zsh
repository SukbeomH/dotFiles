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

# 모던 CLI (설치돼 있을 때만 기본 명령을 대체)
if (( $+commands[eza] )); then
  # 아이콘은 터미널에 직접 출력할 때만 붙인다 (파이프 출력에는 섞이지 않게).
  # eza 0.23 의 --icons=auto 는 터미널에서도 아이콘을 내지 않아 직접 판별한다.
  _eza() {
    local icons=never
    [[ -t 1 ]] && icons=always
    command eza --icons=$icons "$@"
  }
  alias ls='_eza'
  alias ll='_eza -la --git'
  alias lt='_eza --tree --level=2'
else
  alias ll='ls -lah'
fi
# cat 자리에서는 테두리·줄 번호 없이 구문 강조만 한다. 전체 장식은 bat 을 직접 쓴다.
(( $+commands[bat] )) && alias cat='bat --paging=never --style=plain'

# 기타
alias reload='exec zsh -l'
