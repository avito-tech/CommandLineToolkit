ACTION_PREFIX="action___"

# Removes action from list of available actions.
# If for some reason default action doesn't work or make sense, it can be removed.
__disable_action() {
    local action_name=$1
    local action_function="${ACTION_PREFIX}${action_name}"
    
    unset -f "$action_function"
}

__execute_action() {
    [ $# == 0 ] && __fatal_error "Action is not specified. Usage: \`execute_action <action name> <optional arguments...>\`"

    local project_dir=$1
    local action_name=$2
    shift
    shift
    
    local action_function="${ACTION_PREFIX}${action_name}"

    if __list_all_action_functions | grep --quiet --extended-regexp "^$action_function$"; then
        "$action_function" "$@"
    else
        __fatal_error "Action ${action_name} is not defined. You can add ${action_function} to \`custom_actions.sh\` in your project dir (PROJECT_DIR: ${project_dir})"
    fi
}

__all_actions() {
    __list_all_action_functions | __convert_from_action_function_to_action_name
}

__convert_from_action_function_to_action_name() {
    sed "s/^$ACTION_PREFIX//g"
}

__list_all_action_functions() {
    __list_all_bash_functions | grep -E "^$ACTION_PREFIX"
}

__list_all_bash_functions() {
    compgen -A function
}

__load_custom_actions() {
    local project_dir=$1
    
    if [ -f "${project_dir}/custom_actions.sh" ]; then
        source "${project_dir}/custom_actions.sh"
    fi
}