function killname
    pkill -9 -f $argv[1]
    and echo "Killed processes matching '$argv[1]'"
    or echo "No process found matching '$argv[1]'"
end
