# Keeps node_modules/.git out of the Spotlight index after installs
function spotlight_block
    test -d node_modules; and touch node_modules/.metadata_never_index
    test -d .git; and touch .git/.metadata_never_index
    return 0
end
