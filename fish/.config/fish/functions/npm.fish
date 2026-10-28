function npm
    command npm $argv
    set -l rc $status
    spotlight_block
    return $rc
end
