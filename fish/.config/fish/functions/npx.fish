function npx
    command npx $argv
    set -l rc $status
    spotlight_block
    return $rc
end
