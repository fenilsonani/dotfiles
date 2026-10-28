# Open or reattach a zmx session (default "main"); ctrl+\ detaches
function t
    set -l name main
    set -q argv[1]; and set name $argv[1]
    zmx attach $name
end
