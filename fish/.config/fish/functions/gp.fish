# Unsets the invalid GITHUB_TOKEN that IDE extensions export
function gp
    env -u GITHUB_TOKEN git push $argv
end
