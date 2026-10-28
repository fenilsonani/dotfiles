# yazi that leaves the shell in the directory you quit in
function y
    set -l tmp (mktemp -t yazi-cwd.XXXXXX)
    command yazi $argv --cwd-file="$tmp"
    if read -z -l cwd <$tmp; and test -n "$cwd"; and test "$cwd" != "$PWD"; and test -d "$cwd"
        builtin cd -- $cwd
    end
    command rm -f -- $tmp
end
