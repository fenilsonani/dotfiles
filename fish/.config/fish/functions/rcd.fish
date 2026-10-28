# zmx run feeds commands /dev/null as stdin, so create the session with run, then send the command for a real TTY (trust prompt)
function rcd
    set -l n (basename $PWD)
    set -q argv[1]; and set n $argv[1]
    zmx run "rc-$n" true >/dev/null
    and zmx send "rc-$n" "claude remote-control --name '$n' --permission-mode bypassPermissions"\r
    and echo "Remote Control started in zmx session rc-$n (attach: t rc-$n)"
end
