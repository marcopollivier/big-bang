# ~/.zshrc — symlinkado deste repo (big-bang/dotfiles/.zshrc) pelo `just link`.
# Editar aqui OU na home é a mesma coisa (é o mesmo arquivo). Config específica
# da máquina e segredos vão em ~/.zshrc.local (gitignored), carregado no fim.

## oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""   # prompt gerenciado pelo starship (init no fim do arquivo)
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"

# Plugins (aliases/completions). Plugin aqui ≠ binário instalado — os programas
# em si vêm do Brewfile/mise.
plugins=(
    #Password mgmt
    1password

    # MacOS
    brew

    #Tools
    aliases
    command-not-found

    #Docker e K8s
    docker
    docker-compose
    kubectl

    #Infra
    ansible
    terraform
    opentofu
    vagrant

    #DB
    postgres
    redis-cli

    #Dev
    aws
    git
    vscode

    #Langs
    golang
    rust

    #JVM Family
    mvn
    gradle
    lein

    #Python (versões via mise)
    pip
    python
    virtualenv

    #NodeJS (versões via mise)
    node
    npm
    yarn
    )

# Guard: sem oh-my-zsh o shell segue funcionando (instale com `just omz`)
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
else
  echo "big-bang: oh-my-zsh não encontrado em $ZSH — rode 'just omz' no repo" >&2
fi

## Editor padrão
export EDITOR=nvim
export VISUAL=nvim

## Aliases
alias lg="lazygit"
alias ld="lazydocker"
alias vscode="code"
alias python="python3"
alias tf="tofu"
alias tofy="tofu"
alias vim="nvim"
alias vi="nvim"
alias ls="eza --icons=auto"
alias ll="eza -lh --git --icons=auto"
alias la="eza -lah --git --icons=auto"
alias cat="bat --paging=never"
#Only if is using podman instead of docker
# alias docker="podman"

## History Custom Configuration
# HISTORY
export HISTFILE=~/.zsh_history
export HISTSIZE=5000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt SHARE_HISTORY             # Share history between all sessions.
# END HISTORY

## Brew
export PATH="/opt/homebrew/bin:$PATH"
eval $(/opt/homebrew/bin/brew shellenv)

## Auto-update do Homebrew — no máx. 1x/dia, em background (não trava o prompt).
## Só fórmulas: cask em Mac gerenciado pede sudo e travaria em background.
## Log: ~/.cache/brew-autoupdate.log
_brew_autoupdate() {
    local stamp="${XDG_CACHE_HOME:-$HOME/.cache}/brew-autoupdate.stamp"
    local log="${XDG_CACHE_HOME:-$HOME/.cache}/brew-autoupdate.log"
    mkdir -p "${stamp:h}"
    if [[ -f "$stamp" ]]; then
        local last=$(stat -f %m "$stamp" 2>/dev/null || echo 0)
        (( $(date +%s) - last < 86400 )) && return   # rodou há menos de 24h
    fi
    touch "$stamp"   # marca o slot já, pra abas paralelas não dispararem juntas
    ( brew update && brew upgrade --formula && brew cleanup ) >"$log" 2>&1 &!
}
command -v brew >/dev/null && _brew_autoupdate

## mise — gerenciador de versões (substitui asdf/nvm/pyenv)
command -v mise >/dev/null && eval "$(mise activate zsh)"

## fzf — busca fuzzy + keybindings (Ctrl-R, Ctrl-T)
command -v fzf >/dev/null && source <(fzf --zsh)

## zsh-autosuggestions — sugestão (cinza) do próximo comando a partir do histórico; aceita com →
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] \
    && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

## .local bin
export PATH="$HOME/.local/bin":$PATH

## Golang
export PATH="$HOME/go/bin:$PATH"   # binários de `go install` (Go gerenciado pelo mise)

## Java
## JAVA_HOME é provido pelo mise (plugin java)

# --- Guardrails de techs que já usei / posso voltar a usar ---------------
# Seções de reserva: sem config ativa hoje, mas o lugar de cada coisa já
# está marcado pra quando a tech voltar (ex.: na máquina pessoal).

## Clojure
## -- sem config ativa -- (aliases globais já são seedados em ~/.clojure/deps.edn)

### Gradle
## -- sem config ativa --
# export GRADLE_USER_HOME="$HOME/.gradle"   # exemplo: cache/props fora do default

### Maven
## -- sem config ativa --
# export MAVEN_OPTS="-Xmx2g"                # exemplo: memória do build

## NodeJS
## -- sem config ativa -- (Node vem do mise; NPM_TOKEN vive em ~/.zshrc.local e é lido pelo ~/.npmrc)
# --------------------------------------------------------------------------

## Docker, Podman e K8s
# Limpa DOCKER_HOST pra ferramentas (docker CLI, testcontainers) usarem o socket
# padrão — que no macOS é provido pelo podman-mac-helper (ver README, FAQ).
export DOCKER_HOST=

# Contextos EKS parametrizados — defina EKS_PRD_ARN e EKS_HML_ARN em ~/.zshrc.local
function k8s-p() {
    kubectl config use-context "${EKS_PRD_ARN:?defina EKS_PRD_ARN em ~/.zshrc.local}" && kubectl "$@"
}

function k8s-h() {
    kubectl config use-context "${EKS_HML_ARN:?defina EKS_HML_ARN em ~/.zshrc.local}" && kubectl "$@"
}

# !!!!!! DANGEROUS ZONE — dados sensíveis !!!!!!
# Chaves e segredos NÃO vivem neste arquivo (ele é versionado no repo).
# Vivem em ~/.zshrc.local, que é gitignored e nunca sai da máquina — os
# blocos abaixo são só os APONTAMENTOS para eles.

## GPG (assinatura de commits — a chave em si fica no keyring, não aqui)
export GPG_TTY=$(tty)
command -v gpgconf >/dev/null && gpgconf --kill gpg-agent

## Segredos e config específica da máquina (NÃO commitado)
## Defina lá: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN,
## GITHUB_TOKEN, NPM_TOKEN, EKS_PRD_ARN, EKS_HML_ARN, etc.
## Referência: ~/.zshrc.local.example
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
# !!!!!! fim da DANGEROUS ZONE !!!!!!

## Prompt (starship) — substitui o tema do oh-my-zsh. Config: ~/.config/starship.toml
command -v starship >/dev/null && eval "$(starship init zsh)"
