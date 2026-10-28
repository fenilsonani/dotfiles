function pnpmi
    command pnpm install $argv
    set -l rc $status
    spotlight_block
    return $rc
end
