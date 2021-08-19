install_executable() {
    local executable_name=$1
    local destination_path=${2:-$PROJECT_DIR/$executable_name}

    local number_of_matching_executables
    number_of_matching_executables=$(__find_matching_executables_in_build_folder "$executable_name"|wc -l)

    if [[ "$number_of_matching_executables" -ne 1 ]]; then
        __fatal_error "Expected to find exactly 1 executable, found $number_of_matching_executables"
    else
        local executable_path
        executable_path=$(__find_matching_executables_in_build_folder "$executable_name")
        mv -f "$executable_path" "$destination_path"
    fi
}

__find_matching_executables_in_build_folder() {
    local executable_name=$1
    
    find .build -name "$executable_name" -type f -perm +111
}