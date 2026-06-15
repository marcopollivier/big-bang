# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""   # prompt gerenciado pelo starship (init no fim do arquivo)

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
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

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Editor padrão
export EDITOR=nvim
export VISUAL=nvim

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias lg="lazygit"
alias ld="lazydocker"
alias lnpm="lazynpm"
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

## .local bin
export PATH="$HOME/.local/bin":$PATH

## Clojure
## -- sem config personalizada -- 

## Golang 
export PATH="$HOME/go/bin:$PATH"   # binários de `go install` (Go gerenciado pelo mise)

## Java
## JAVA_HOME é provido pelo mise (plugin java)

### Gradle
## -- sem config personalizada -- 

### Maven
## -- sem config personalizada -- 

## NodeJS
## -- sem config personalizada -- 

## Docker, Podman e K8s
export DOCKER_HOST=

# Contextos EKS parametrizados — defina EKS_PRD_ARN e EKS_HML_ARN em ~/.zshrc.local
function k8s-p() {
    kubectl config use-context "${EKS_PRD_ARN:?defina EKS_PRD_ARN em ~/.zshrc.local}" && kubectl "$@"
}

function k8s-h() {
    kubectl config use-context "${EKS_HML_ARN:?defina EKS_HML_ARN em ~/.zshrc.local}" && kubectl "$@"
}

# !!!!!! DANGEROUS ZONE !!!!!!

## GPG
export GPG_TTY=$(tty)
command -v gpgconf >/dev/null && gpgconf --kill gpg-agent

## Segredos e config específica da máquina (NÃO commitado)
## Defina aqui: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN,
## GITHUB_TOKEN, EKS_PRD_ARN, EKS_HML_ARN, etc.
## Referência: ~/.zshrc.local.example
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

## Prompt (starship) — substitui o tema do oh-my-zsh. Config: ~/.config/starship.toml
command -v starship >/dev/null && eval "$(starship init zsh)"
