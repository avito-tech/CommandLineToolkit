build_and_export_executable() {
    local executable_name=$1 # basename of file in release build folder
    local destination_path=$2 # exact file path or folder
    local archs_to_build=("${@:3}") # architectures to build into fat binary

    if [ ${#archs_to_build[@]} -eq 1 ]; then
        # binaries for single architecture are built into this folder
        local executable_path="$PROJECT_DIR/.build/release/$executable_name"
    else
        # fat binaries are built into this folder
        # if archs_to_build is empty, we build fat binary for all available architectures
        local executable_path="$PROJECT_DIR/.build/apple/Products/Release/$executable_name"
    fi
    
    action___build ${archs_to_build[@]+"${archs_to_build[@]}"}
    export_executable "$executable_path" "$destination_path"
}

export_executable() {
    local executable_path=$1
    local destination_path=$2

    strip "$executable_path"
    mv -f "$executable_path" "$destination_path"
}

# args: shell command
perform_inside_project() {
    __perform_inside_folder "$PROJECT_DIR" "$@"
}

# args: `IFS` then shell command
with_internal_field_separator() {
    local savedIFS=$IFS
    IFS=$1
    shift 1
    "$@"
    IFS=$savedIFS
}

# args: `grep_pattern` then shell command
perform_ignoring_nonzero_exit_status_if_stderr_contains() {
    local grep_pattern=$1
    shift 1
    
    local result=0

    local stderr_path
    stderr_path="$(__make_temporary_directory)/stderr.log"

	$@ 2> >(tee -a "$stderr_path" >&2) || result=$?

    if [ $result != 0 ]; then
        if grep "no tests found" "$stderr_path" 1>/dev/null; then
            # ok
            return 0
        else
            return $result
        fi
    fi
}