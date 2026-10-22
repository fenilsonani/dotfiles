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
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting
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
# Remote Control server for the current directory (adds it to the phone's "Choose directory" list)
alias rc='claude remote-control --permission-mode bypassPermissions'
# Same, but in a detached zmx session so it survives closing the terminal: rcd [name]
# zmx run feeds commands /dev/null as stdin, so create the session with run, then send the command for a real TTY (trust prompt)
rcd() { local n="${1:-${PWD##*/}}"; zmx run "rc-$n" true >/dev/null && zmx send "rc-$n" "claude remote-control --name '$n' --permission-mode bypassPermissions"$'\r' && echo "Remote Control started in zmx session rc-$n (attach: t rc-$n)"; }

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
# Agents parse ls output, so eza only replaces ls outside Claude Code
if [[ -z $CLAUDECODE ]] && (( $+commands[eza] )); then
  alias ls='eza --group-directories-first'
  alias l='eza -la --git --group-directories-first'
  alias la='eza -la --group-directories-first'
  alias ll='eza -l --git --group-directories-first'
  alias lt='eza --tree --level=2 --git-ignore'
else
  alias l='ls -lah'
  alias la='ls -lAh'
  alias ll='ls -lh'
  alias ls='ls -G'
fi
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
# iTerm.app/Contents/Resources/utilities ships its own it2 that shadows the uv-installed one Claude Code agent teams expect
export PATH="$HOME/.local/priority-bin:$PATH"
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

[ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"

[[ -z $CLAUDECODE ]] && command -v atuin >/dev/null && eval "$(atuin init zsh)"

# Spotlight: auto-block indexing of junk dirs after install
# Spotlight: keep node_modules/.git out of the index. NO leading underscore on the
# function name: Claude Code's shell snapshot drops _-prefixed functions, which made
# every agent `npm` call exit 127 ("command not found: _spotlight_block").
spotlight_block() {
  [ -d node_modules ] && touch node_modules/.metadata_never_index
  [ -d .git ] && touch .git/.metadata_never_index
  return 0
}
npm()   { command npm "$@";          local rc=$?; spotlight_block; return $rc; }
npx()   { command npx "$@";          local rc=$?; spotlight_block; return $rc; }
buni()  { command bun install "$@";  local rc=$?; spotlight_block; return $rc; }
pnpmi() { command pnpm install "$@"; local rc=$?; spotlight_block; return $rc; }


# Secrets live in ~/.zshrc.local (untracked; this file is in a public dotfiles repo)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Added by Cap
export PATH="/Users/fenilsonani/.cap/bin:$PATH"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/fenilsonani/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# --- Qwen3-Coder-30B (MLX) helpers ---
alias qwen='mlx_lm.chat --model mlx-community/Qwen3-Coder-30B-A3B-Instruct-6bit'
alias qwen-serve='mlx_lm.server --model mlx-community/Qwen3-Coder-30B-A3B-Instruct-6bit --port 8080'
alias qwen-gen='mlx_lm.generate --model mlx-community/Qwen3-Coder-30B-A3B-Instruct-6bit --max-tokens 512 --temp 0.2 --prompt'
# ------------------------------------

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<

alias sshair='ssh fenilsonani@air'
alias sshvps='ssh fenilsonani@vps'

# Tailscale (talks to daemon on /var/run/tailscaled.socket — works for both the
# GUI extension and a homebrew tailscaled LaunchDaemon)
tailscale() { /opt/homebrew/bin/tailscale --socket=/var/run/tailscaled.socket "$@" }
alias ts='tailscale'
alias tss='tailscale status'
alias tsip='tailscale ip -4'
alias tsping='tailscale ping'
alias tsup='tailscale up'
alias tsdown='tailscale down'
alias tsnet='tailscale netcheck'

# --- CLI shims for agents -----------------------------------------------------
# Agents call these bare (tsc alone missed 377 times in transcripts). Resolve through the
# repo's own node_modules via bunx instead of failing with "command not found".
for _c in tsc vitest tsx playwright turbo wrangler; do
  eval "$_c() { bunx $_c \"\$@\"; }"
done; unset _c
# keg-only libpq (psql, pg_isready) and Android platform-tools (adb) are off PATH by default
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# Resend CLI
export PATH="$HOME/.resend/bin:$PATH"

# t [name]: open or reattach a zmx session (default "main"); ctrl+\ detaches
t() { zmx attach "${1:-main}"; }
[[ -n $ZMX_SESSION ]] && PROMPT="[$ZMX_SESSION] $PROMPT"
# ── kitty kittens (only inside kitty) ─────────────────
if [[ "$TERM" == "xterm-kitty" ]]; then
  alias ssh="kitten ssh"            # ssh that brings kitty features along
  alias icat="kitten icat"          # show image: icat pic.png
  alias kd="kitten diff"            # side-by-side diff: kd a b
  alias kcp="kitten clipboard"      # pipe to Mac clipboard (works over ssh): cmd | kcp
  alias kpaste="kitten clipboard --get-clipboard"
  alias send="kitten transfer"      # copy file over current ssh: send file
fi

zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --group-directories-first $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'

export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'

# Hook-based tools init only outside Claude Code (its snapshot drops _-prefixed functions); agents get mise shims instead
if [[ -z $CLAUDECODE ]]; then
  (( $+commands[mise] )) && eval "$(mise activate zsh)"
  # key-bindings only: fzf's completion.zsh would steal Tab from fzf-tab; empty CTRL_R leaves Ctrl+R to atuin
  FZF_CTRL_R_COMMAND=
  [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
else
  (( $+commands[mise] )) && eval "$(mise activate zsh --shims)"
fi

alias lg='lazygit'

# y: yazi that leaves the shell in the directory you quit in
y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  command rm -f -- "$tmp"
}

# p [query]: fuzzy-pick a zoxide dir, cd there, and attach its zmx session (named after the dir)
p() {
  local d
  d=$(zoxide query -l | fzf --query="$*" --select-1 --height=45% --layout=reverse \
    --preview='eza -1 --color=always --group-directories-first {}') || return
  builtin cd -- "$d" || return
  [[ -n $ZMX_SESSION ]] || zmx attach "${d:t}"
}

# Setting this replaces zoxide's built-in fzf flags, so they are restated with an eza preview
export _ZO_FZF_OPTS="--exact --no-sort --bind=ctrl-z:ignore,btab:up,tab:down --cycle --keep-right --border=sharp --height=45% --info=inline --layout=reverse --tabstop=1 --exit-0 --preview='eza -1 --color=always --group-directories-first {2..}' --preview-window=down,30%,sharp"
export _ZO_EXCLUDE_DIRS="$HOME:/tmp/*:/private/*:*/node_modules/*:*/.git/*"
# zoxide must init last. Skipped under Claude Code: its shell snapshot drops _-prefixed
# functions, leaving z and the chpwd hook calling missing __zoxide_* helpers on every cd.
[[ -z $CLAUDECODE ]] && command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
