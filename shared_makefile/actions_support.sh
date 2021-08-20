build_and_export_executable() {
    local executable_name=$1 # basename of file in release build folder
    local destination_path=$2 # exact file path or folder

    local executable_path="$PROJECT_DIR/.build/release/$executable_name"
    
    action___build
    export_executable "$executable_path" "$destination_path"
}

export_executable() {
    local executable_path=$1
    local destination_path=$2

    strip "$executable_path"
    mv -f "$executable_path" "$destination_path"
}