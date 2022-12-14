build_and_deploy_executable_to_local_path() {
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

    prepare_executable_and_deploy_to_local_path "$executable_path" "$destination_path"
}

prepare_executable_and_deploy_to_local_path() {
    local executable_path=$1
    local destination_path=$2

    strip "$executable_path"
    /usr/bin/codesign --force --sign - --timestamp=none "$executable_path"
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
        if grep "$grep_pattern" "$stderr_path" 1>/dev/null; then
            # ok
            return 0
        else
            return $result
        fi
    fi
}

# Note: to make `xcscheme.template` for another project, create it first in Xcode,
# copy it from .swiftpm directory (see `__get_target_schemes_directory`),
# modify it the same way as for other xcsheme templates, and add
# code to project's `custom_action.sh` the same way as for other project's `custom_action.sh`
generate_scheme() {
    local default_scheme_template_path="$PROJECT_DIR/xcscheme.template"

    local scheme_name=$1
    local render_template_function=$2  # should process template from stdin and render scheme to stdout
    local scheme_template_path=${3:-$default_scheme_template_path}

    body() {
        local target_schemes_directory; target_schemes_directory=$(__get_target_schemes_directory)

        local target_scheme="$target_schemes_directory/$scheme_name.xcscheme"
        mkdir -p "$(dirname "$target_scheme")"

        "$render_template_function" < "$scheme_template_path" > "$target_scheme"
    }

    perform_inside_project \
        with_internal_field_separator $'\n' \
        body
}

remove_old_schemes() {
    rm -f "$(__get_target_schemes_directory)"/*.xcscheme
}

# Arguments: command line arguments.
# Renders XML to stdout.
# Example:
# ```
# make_command_line_arguments_plist_entry my_project_command --my-project-command-argument
# ```
make_command_line_arguments_plist_entry() {
    while [ $# -gt 0 ]; do
        echo "         <CommandLineArgument"
        echo "            argument = \"$1\""
        echo "            isEnabled = \"YES\">"
        echo "         </CommandLineArgument>"
        shift
    done
}

__get_target_schemes_directory() {
    echo "$PROJECT_DIR/.swiftpm/xcode/xcshareddata/xcschemes/"
}
