# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="refined"

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
zstyle ':omz:update' mode auto      # update automatically without asking
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
ENABLE_CORRECTION="true"

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
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  z
  docker
  docker-compose
  kubectl
  npm
  node
  python
  pip
  brew
  macos
  vscode
  web-search
  colored-man-pages
  command-not-found
  extract
  history
  sudo
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export PATH=$PATH:/Library/TeX/texbin 

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nano'
fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"
# Custom Aliases
alias cc='claude --dangerously-skip-permissions'
alias ccr='claude --dangerously-skip-permissions --resume'
alias ccc='claude --dangerously-skip-permissions --continue'
alias cx='codex --dangerously-bypass-approvals-and-sandbox'
alias cxr='codex resume --dangerously-bypass-approvals-and-sandbox'
alias cxc='codex resume --last --dangerously-bypass-approvals-and-sandbox'

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'
alias dd='cd ~/Developer/ && ls'

# SSH alias to the server
alias sshfenil='ssh fenilsonani@159.195.74.166'

# List directory contents
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias ls='ls -G'
alias lsa='ls -lah'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gb='git branch'
# Git push with proper auth (unsets invalid GITHUB_TOKEN from IDE extensions)
unalias gp 2>/dev/null
gp() { (unset GITHUB_TOKEN; git push "$@") }
alias gpl='git pull'
alias gd='git diff'
alias glog='git log --oneline --decorate --graph'
alias gstash='git stash'
alias greset='git reset --hard'

# Docker aliases
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs'
alias drm='docker rm'
alias drmi='docker rmi'
alias dstop='docker stop'
alias dstart='docker start'

# System aliases
alias reload='source ~/.zshrc'
alias zshconfig='${EDITOR:-nano} ~/.zshrc'
alias ohmyzsh='${EDITOR:-nano} ~/.oh-my-zsh'
alias o='open .'
alias of='open -R'
alias pwdc='pwd | pbcopy'
alias h='history'
alias hgrep='history | grep'
alias cls='clear'
alias md='mkdir -p'
alias rd='rmdir'
alias df='df -h'
alias du='du -h'
alias free='free -m'

# Network aliases
alias ip='curl ifconfig.me'
alias localip='ipconfig getifaddr en0'
alias ping='ping -c 5'
alias ports='netstat -tulanp'

# Kill process on specific port
killport() { lsof -ti:$1 | xargs kill -9 2>/dev/null && echo "Killed process on port $1" || echo "No process found on port $1"; }

# Show all processes listening on ports (table view)
alias listening='lsof -iTCP -sTCP:LISTEN -P -n | awk "NR==1 {print \"COMMAND\", \"PID\", \"USER\", \"PORT\"} NR>1 {split(\$9,a,\":\"); print \$1, \$2, \$3, a[length(a)]}" | column -t'

# Show what's running on a specific port
portinfo() { lsof -i :$1 -P -n; }

# Kill process by name
killname() { pkill -9 -f "$1" && echo "Killed processes matching '$1'" || echo "No process found matching '$1'"; }

# File operations
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -pv'

# Search aliases
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias find='find . -name'

# Python aliases
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'

# Node/NPM aliases
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias ns='npm start'
alias nt='npm test'

# Markdown viewer aliases (Glow)
alias md='glow'
alias mdv='glow'
alias readme='glow README.md'
alias mdb='glow -a'  # Browse all markdown in git repo
alias mdp='glow -p'  # Page through markdown file
alias nr='npm run'
alias nrb='npm run build'
alias nrd='npm run dev'

# Bun aliases
alias bi='bun install'
alias ba='bun add'
alias bad='bun add --dev'
alias bs='bun start'
alias bt='bun test'
alias bb='bun build'
alias bd='bun dev'
alias br='bun run'
alias bx='bunx'
alias bu='bun update'
alias brm='bun remove'
alias bw='bun run --watch'
alias btw='bun test --watch'
alias bclean='rm -rf node_modules bun.lockb && bun install'
alias bout='bun outdated'
alias blink='bun link'
alias bunlink='bun unlink'

# Bun + Next.js aliases
alias bnext='bunx create-next-app@latest'
alias bnextdev='bun run dev'
alias bnextbuild='bun run build'
alias bnextstart='bun run start'
alias bnextlint='bun run lint'

# Bun create project aliases
alias bcreate='bun create'
alias breact='bun create react'
alias bvite='bun create vite'
alias bsveltekit='bun create svelte@latest'
alias bastro='bun create astro@latest'
alias bnuxt='bunx nuxi@latest init'
alias bremix='bunx create-remix@latest'
alias bhono='bun create hono'
alias belysia='bun create elysia'

# Bun script shortcuts
alias blint='bun run lint'
alias bformat='bun run format'
alias bprettier='bun run prettier'
alias btypecheck='bun run typecheck'
alias bcheck='bun run check'
alias bpre='bun run preview'

# Bun with Turbo/monorepo
alias bturbo='bun run turbo'
alias bturbod='bun run turbo dev'
alias bturbob='bun run turbo build'

# Bun utilities
alias bunv='bun --version'
alias bunup='bun upgrade'
alias bunpm='bun pm'
alias bunpmls='bun pm ls'
alias bunpmcache='bun pm cache'

# pnpm aliases
alias pni='pnpm install'
alias pna='pnpm add'
alias pnad='pnpm add --save-dev'
alias pnag='pnpm add --global'
alias pns='pnpm start'
alias pnt='pnpm test'
alias pnb='pnpm build'
alias pnd='pnpm dev'
alias pnr='pnpm run'
alias pnx='pnpx'
alias pnu='pnpm update'
alias pnrm='pnpm remove'

# macOS specific aliases
alias showfiles='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
# alias cleanup='find . -type f -name "*.DS_Store" -ls -delete'  # Commented out for CleanupCache CLI tool
alias emptytrash='sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl'

# Quick edit common files
alias hosts='sudo ${EDITOR:-nano} /etc/hosts'
alias sshconfig='${EDITOR:-nano} ~/.ssh/config'
alias gitconfig='${EDITOR:-nano} ~/.gitconfig'
export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

# Created by `pipx` on 2025-09-09 04:37:48
export PATH="$PATH:/Users/fenilsonani/.local/bin"
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

eval "$(/usr/libexec/path_helper)"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# opencode
export PATH=/Users/fenilsonani/.opencode/bin:$PATH

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/fenilsonani/.lmstudio/bin"
# End of LM Studio CLI section


# bun completions
[ -s "/Users/fenilsonani/.bun/_bun" ] && source "/Users/fenilsonani/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"

# Added by Windsurf
export PATH="/Users/fenilsonani/.codeium/windsurf/bin:$PATH"

# Added by Antigravity
export PATH="/Users/fenilsonani/.antigravity/antigravity/bin:$PATH"

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
