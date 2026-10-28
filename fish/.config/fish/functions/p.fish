# Fuzzy-pick a zoxide dir, cd there, and attach its zmx session (named after the dir)
function p
    set -l d (zoxide query -l | fzf --query="$argv" --select-1 --height=45% --layout=reverse \
        --preview='eza -1 --color=always --group-directories-first {}'); or return
    builtin cd -- $d; or return
    set -q ZMX_SESSION; or zmx attach (basename $d)
end
