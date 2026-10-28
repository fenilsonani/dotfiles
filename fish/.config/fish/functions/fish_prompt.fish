# Mirrors oh-my-zsh's "refined" theme: cwd and git on one line, a status-colored arrow below
function fish_prompt
    set -l last_status $status
    set -g __fish_git_prompt_showdirtystate 1
    set -g __fish_git_prompt_char_dirtystate '*'
    set -g __fish_git_prompt_char_stagedstate '*'
    echo
    set -q ZMX_SESSION; and echo -n "[$ZMX_SESSION] "
    set_color blue
    echo -n (prompt_pwd --full-length-dirs=99)
    set_color brblack
    fish_vcs_prompt ' %s'
    if test $CMD_DURATION -gt 5000
        set_color yellow
        echo -n ' '(math -s0 $CMD_DURATION / 1000)s
    end
    echo
    if test $last_status -eq 0
        set_color magenta
    else
        set_color red
    end
    echo -n ❯' '
    set_color normal
end
