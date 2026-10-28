function listening
    lsof -iTCP -sTCP:LISTEN -P -n | awk 'NR==1 {print "COMMAND", "PID", "USER", "PORT"} NR>1 {split($9,a,":"); print $1, $2, $3, a[length(a)]}' | column -t
end
