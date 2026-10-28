function portinfo
    lsof -i :$argv[1] -P -n
end
