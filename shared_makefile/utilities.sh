# Note: requires to have `.reporoot` file
__set_repo_root() {
    [ -z "${REPO_ROOT:-}" ] || return 0
    
    REPO_ROOT="$(python_realpath "$0")"
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

__close_spm_package_in_xcode_saving_changes() {
    local xcode_app_name; xcode_app_name=$(xcode-select -p | grep -oE "([^/]+.app)" | sed 's/\.app//')
    local package_directory_path_absolute=$PROJECT_DIR
    
    # Note: to get API of Xcode, open "Script Editor", select "File" -> "Open Dictionary...", select Xcode
    osascript -e '
        tell application "'"$xcode_app_name"'"
            if count of workspace documents > 0 then
                repeat with index_of_document from 0 to count of workspace documents
                    set document_path to path of workspace document index_of_document

                    considering case
                        if document_path = "'"$package_directory_path_absolute"'" then
                            tell workspace document index_of_document
                                close saving yes
                            end tell
                            exit repeat
                        end if
                    end considering
                end repeat
            end if
        end tell'
}