# Talks to the daemon on /var/run/tailscaled.socket, which serves both the GUI extension and a homebrew LaunchDaemon
function tailscale
    /opt/homebrew/bin/tailscale --socket=/var/run/tailscaled.socket $argv
end
