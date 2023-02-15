# Notes:
# - action___foo_bar is for overriding
# - default_action___foo_bar is not for overriding, but can be reused in overriden functions

# shellcheck disable=SC2120
action___generate() { default_action___generate ${@+"$@"}; }
default_action___generate() {
    local toolkit_dirname="$SHARED_MAKE_SH_DIRNAME/.."

    # Assume that everybody depends on CommandLineToolkit and generate package for it:
    make -f "${toolkit_dirname}/Makefile" -C "${toolkit_dirname}" generate

    swift run --package-path "${toolkit_dirname}/PackageGenerator/" package-gen "$PROJECT_DIR"
}

action___open() { default_action___open ${@+"$@"}; }
default_action___open() {
    __close_spm_package_in_xcode_saving_changes
    
    action___generate
    
    perform_inside_project open Package.swift
}

action___clean() { default_action___clean ${@+"$@"}; }
default_action___clean() {
    perform_inside_project rm -rf .build/
}

action___build() { default_action___build ${@+"$@"}; }
default_action___build() {
    action___generate
    local arch_options; arch_options=$(__make_swift_build_arch_options "$@")
    perform_inside_project swift build $arch_options -c release -Xswiftc -Osize
}

action___build_debug() { default_action___build_debug ${@+"$@"}; }
default_action___build_debug() {
    action___generate
    local arch_options; arch_options=$(__make_swift_build_arch_options "$@")
    perform_inside_project swift build $arch_options -c debug -Xswiftc -Onone
}

action___test() { default_action___test ${@+"$@"}; }
default_action___test() {
    action___generate
    
    if [ "${SUPPRESS_ERROR_WHEN_NO_TESTS_FOUND:-false}" == "true" ]; then
        perform_ignoring_nonzero_exit_status_if_stderr_contains "no tests found" \
            perform_inside_project \
            swift test --parallel "$@"
    else
        perform_inside_project \
            swift test --parallel "$@"
    fi
}

action___run_ci_tests() { default_action___run_ci_tests ${@+"$@"}; }
default_action___run_ci_tests() {
    export ON_CI=true
    export SHOULD_VERIFY_THAT_PACKAGE_CONTENTS_ARE_UNCHANGED=true
    action___test --enable-code-coverage -Xswiftc -DTEST
}

action___help() { default_action___help ${@+"$@"}; }
default_action___help() {
    echo
    echo "We know the following actions:"
    echo
    for action_name in $(__list_all_action_functions | __convert_from_action_function_to_action_name); do
        local action_help_function_name; action_help_function_name="$(__action_help_function_name "$action_name")"
        if __function_exists "$action_help_function_name"; then
            echo "- $action_name: $($action_help_function_name | __indent_lines_except_first)"
        else
            echo "- $action_name"
        fi
    done
    echo
}

__indent_lines_except_first() {
    perl -pe 's/\n/\n    /'
}
