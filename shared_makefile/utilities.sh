__set_repo_root() {
    [ -z "${REPO_ROOT:-}" ] || return 0
    
    REPO_ROOT="$(realpath "$0")"
    while [[ "$REPO_ROOT" != "/" ]]
    do
        if [[ -f "$REPO_ROOT/.reporoot" ]]
        then
            return
        fi
        REPO_ROOT="$(dirname "$REPO_ROOT")"
    done
    echo "Error: can't find repo root"
    exit 1
}

__set_repo_root

# Convenient method to report errors
# Example: cat foo | grep bar || __fatal_error "Can not find bar in foo"
__fatal_error() {
    echo $@
    exit 1
}

# Convenient method to ignore error
# Example: rm foo || __ignore_error"
__ignore_error() {
    true 
}