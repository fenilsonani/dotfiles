/opt/homebrew/bin/brew shellenv fish | source
# node@22 and openjdk@17 sit behind Homebrew so `node` and `java` stay the latest versions, matching zsh
fish_add_path --path --append /opt/homebrew/opt/node@22/bin /opt/homebrew/opt/openjdk@17/bin ~/.cargo/bin ~/.docker/bin ~/.local/bin /Library/TeX/texbin ~/.lmstudio/bin
# iTerm.app/Contents/Resources/utilities ships its own it2 that shadows the uv-installed one Claude Code agent teams expect
fish_add_path --global ~/.local/priority-bin
# keg-only libpq (psql, pg_isready) and Android platform-tools (adb) are off PATH by default
set -gx ANDROID_HOME ~/Library/Android/sdk
fish_add_path --global /opt/homebrew/opt/libpq/bin $ANDROID_HOME/platform-tools $ANDROID_HOME/emulator ~/.resend/bin \
    /opt/homebrew/opt/openjdk/bin ~/.opencode/bin ~/.bun/bin ~/.codeium/windsurf/bin ~/.antigravity/antigravity/bin ~/.cap/bin ~/.grok/bin

set -gx LANG en_US.UTF-8
set -gx BUN_INSTALL ~/.bun
if set -q SSH_CONNECTION
    set -gx EDITOR vim
else
    set -gx EDITOR nano
end

set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --exclude .git'
# Setting this replaces zoxide's built-in fzf flags, so they are restated with an eza preview
set -gx _ZO_FZF_OPTS "--exact --no-sort --bind=ctrl-z:ignore,btab:up,tab:down --cycle --keep-right --border=sharp --height=45% --info=inline --layout=reverse --tabstop=1 --exit-0 --preview='eza -1 --color=always --group-directories-first {2..}' --preview-window=down,30%,sharp"
set -gx _ZO_EXCLUDE_DIRS "$HOME:/tmp/*:/private/*:*/node_modules/*:*/.git/*"

# Secrets live in ~/.config/fish/local.fish (untracked; this file is in a public dotfiles repo)
test -f ~/.config/fish/local.fish; and source ~/.config/fish/local.fish

# Agents call these bare; resolve through the repo's own node_modules via bunx
for c in tsc vitest tsx playwright turbo wrangler
    function $c --inherit-variable c
        bunx $c $argv
    end
end

status is-interactive; or exit

set -g fish_greeting

alias cc 'claude --dangerously-skip-permissions'
alias ccr 'claude --dangerously-skip-permissions --resume'
alias ccc 'claude --dangerously-skip-permissions --continue'
alias cx 'codex --dangerously-bypass-approvals-and-sandbox'
alias cxr 'codex resume --dangerously-bypass-approvals-and-sandbox'
alias cxc 'codex resume --last --dangerously-bypass-approvals-and-sandbox'
alias rc 'claude remote-control --permission-mode bypassPermissions'

abbr -a ... 'cd ../..'
abbr -a .... 'cd ../../..'
abbr -a -- - 'cd -'
abbr -a dd 'cd ~/Developer/ && ls'

abbr -a sshfenil 'ssh fenilsonani@159.195.74.166'
abbr -a sshair 'ssh fenilsonani@air'
abbr -a sshvps 'ssh fenilsonani@vps'
alias keytest '~/.local/bin/keytest'

if command -q eza
    alias ls 'eza --group-directories-first'
    alias l 'eza -la --git --group-directories-first'
    alias la 'eza -la --group-directories-first'
    alias ll 'eza -l --git --group-directories-first'
    alias lt 'eza --tree --level=2 --git-ignore'
else
    alias l 'ls -lah'
    alias la 'ls -lAh'
    alias ll 'ls -lh'
    alias ls 'ls -G'
end
alias lsa 'ls -lah'

abbr -a gs 'git status'
abbr -a ga 'git add'
abbr -a gc 'git commit'
abbr -a gcm 'git commit -m'
abbr -a gco 'git checkout'
abbr -a gb 'git branch'
abbr -a gpl 'git pull'
abbr -a gd 'git diff'
abbr -a glog 'git log --oneline --decorate --graph'
abbr -a gstash 'git stash'
abbr -a greset 'git reset --hard'
abbr -a lg lazygit

abbr -a dps 'docker ps'
abbr -a dpsa 'docker ps -a'
abbr -a di 'docker images'
abbr -a dex 'docker exec -it'
abbr -a dlog 'docker logs'
abbr -a drm 'docker rm'
abbr -a drmi 'docker rmi'
abbr -a dstop 'docker stop'
abbr -a dstart 'docker start'

alias reload 'exec fish'
abbr -a fishconfig '$EDITOR ~/.config/fish/config.fish'
abbr -a o 'open .'
abbr -a of 'open -R'
abbr -a pwdc 'pwd | pbcopy'
abbr -a h history
abbr -a hgrep 'history | grep'
abbr -a cls clear
abbr -a rd rmdir
alias df 'df -h'
alias du 'du -h'

abbr -a ip 'curl ifconfig.me'
abbr -a localip 'ipconfig getifaddr en0'
alias ping 'ping -c 5'
abbr -a ports 'netstat -tulanp'

alias cp 'cp -iv'
alias mv 'mv -iv'
alias mkdir 'mkdir -pv'
alias grep 'grep --color=auto'
alias fgrep 'fgrep --color=auto'
alias egrep 'egrep --color=auto'
alias find 'find . -name'

abbr -a py python3
alias pip pip3
abbr -a venv 'python3 -m venv'
abbr -a activate 'source venv/bin/activate.fish'

abbr -a ni 'npm install'
abbr -a nid 'npm install --save-dev'
abbr -a nig 'npm install -g'
abbr -a ns 'npm start'
abbr -a nt 'npm test'
abbr -a nr 'npm run'
abbr -a nrb 'npm run build'
abbr -a nrd 'npm run dev'

abbr -a md glow
abbr -a mdv glow
abbr -a readme 'glow README.md'
abbr -a mdb 'glow -a'
abbr -a mdp 'glow -p'

abbr -a bi 'bun install'
abbr -a ba 'bun add'
abbr -a bad 'bun add --dev'
abbr -a bs 'bun start'
abbr -a bt 'bun test'
abbr -a bb 'bun build'
abbr -a bd 'bun dev'
abbr -a br 'bun run'
abbr -a bx bunx
abbr -a bu 'bun update'
abbr -a brm 'bun remove'
abbr -a bw 'bun run --watch'
abbr -a btw 'bun test --watch'
abbr -a bclean 'rm -rf node_modules bun.lockb && bun install'
abbr -a bout 'bun outdated'
abbr -a blink 'bun link'
abbr -a bunlink 'bun unlink'
abbr -a bnext 'bunx create-next-app@latest'
abbr -a bnextdev 'bun run dev'
abbr -a bnextbuild 'bun run build'
abbr -a bnextstart 'bun run start'
abbr -a bnextlint 'bun run lint'
abbr -a bcreate 'bun create'
abbr -a breact 'bun create react'
abbr -a bvite 'bun create vite'
abbr -a bsveltekit 'bun create svelte@latest'
abbr -a bastro 'bun create astro@latest'
abbr -a bnuxt 'bunx nuxi@latest init'
abbr -a bremix 'bunx create-remix@latest'
abbr -a bhono 'bun create hono'
abbr -a belysia 'bun create elysia'
abbr -a blint 'bun run lint'
abbr -a bformat 'bun run format'
abbr -a bprettier 'bun run prettier'
abbr -a btypecheck 'bun run typecheck'
abbr -a bcheck 'bun run check'
abbr -a bpre 'bun run preview'
abbr -a bturbo 'bun run turbo'
abbr -a bturbod 'bun run turbo dev'
abbr -a bturbob 'bun run turbo build'
abbr -a bunv 'bun --version'
abbr -a bunup 'bun upgrade'
abbr -a bunpm 'bun pm'
abbr -a bunpmls 'bun pm ls'
abbr -a bunpmcache 'bun pm cache'

abbr -a pni 'pnpm install'
abbr -a pna 'pnpm add'
abbr -a pnad 'pnpm add --save-dev'
abbr -a pnag 'pnpm add --global'
abbr -a pns 'pnpm start'
abbr -a pnt 'pnpm test'
abbr -a pnb 'pnpm build'
abbr -a pnd 'pnpm dev'
abbr -a pnr 'pnpm run'
abbr -a pnx pnpx
abbr -a pnu 'pnpm update'
abbr -a pnrm 'pnpm remove'

abbr -a showfiles 'defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
abbr -a hidefiles 'defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
abbr -a emptytrash 'sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl'
abbr -a hosts 'sudo $EDITOR /etc/hosts'
abbr -a sshconfig '$EDITOR ~/.ssh/config'
abbr -a gitconfig '$EDITOR ~/.gitconfig'

abbr -a qwen 'mlx_lm.chat --model mlx-community/Qwen3-Coder-30B-A3B-Instruct-6bit'
abbr -a qwen-serve 'mlx_lm.server --model mlx-community/Qwen3-Coder-30B-A3B-Instruct-6bit --port 8080'
abbr -a qwen-gen 'mlx_lm.generate --model mlx-community/Qwen3-Coder-30B-A3B-Instruct-6bit --max-tokens 512 --temp 0.2 --prompt'

abbr -a ts tailscale
abbr -a tss 'tailscale status'
abbr -a tsip 'tailscale ip -4'
abbr -a tsping 'tailscale ping'
abbr -a tsup 'tailscale up'
abbr -a tsdown 'tailscale down'
abbr -a tsnet 'tailscale netcheck'

if test "$TERM" = xterm-kitty
    alias ssh 'kitten ssh'
    alias icat 'kitten icat'
    alias kd 'kitten diff'
    alias kcp 'kitten clipboard'
    alias kpaste 'kitten clipboard --get-clipboard'
    alias send 'kitten transfer'
end

command -q mise; and mise activate fish | source
# Empty CTRL_R leaves Ctrl+R to atuin, which binds after fzf
set -gx FZF_CTRL_R_COMMAND
command -q fzf; and fzf --fish | source
command -q atuin; and atuin init fish | source
command -q zoxide; and zoxide init fish | source
