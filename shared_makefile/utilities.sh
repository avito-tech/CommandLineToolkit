# Note: requires to have `.reporoot` file
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

# Example: __perform_inside_folder "folder_name" any command
__perform_inside_folder() {
    local folder=$1
    shift
    
    pushd "$folder" > /dev/null
    "$@"
    popd > /dev/null
}

__make_temporary_directory() {
    local directory
    directory="/tmp/$(uuidgen)" 1>/dev/null
    
    mkdir -p "$directory" 1>/dev/null
    
    echo "$directory"
}

__echo_error() {
    echo "$@" 1>&2
}

# Convenient method to report errors
# Example: cat foo | grep bar || __fatal_error "Can not find bar in foo"
__fatal_error() {
    __echo_error "$@"
    exit 1
}

# Convenient method to ignore error
# Example: rm foo || __ignore_error"
__ignore_error() {
    true 
}

# Return --arch options formed from input arguments.
# If input arguments are empty, return all availabile --arch options.
# Example:
# __make_swift_build_arch_options x86_64    ->    --arch x86_64
# __make_swift_build_arch_options           ->    --arch arm64 --arch x86_64
#
__make_swift_build_arch_options() {
    local input_archs=("$@")
    local all_archs=(
      arm64
      x86_64
    )
    local archs=("${input_archs[@]:-${all_archs[@]}}") # all_archs if input_archs are empty, otherwise input_archs
    local arch_options=()
    for arch in "${archs[@]}"; do
        arch_options+=("--arch $arch")
    done
    echo "${arch_options[@]}"
}