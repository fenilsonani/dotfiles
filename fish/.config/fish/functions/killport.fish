function killport
    lsof -ti:$argv[1] | xargs kill -9 2>/dev/null
    and echo "Killed process on port $argv[1]"
    or echo "No process found on port $argv[1]"
end
