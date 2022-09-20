action___generate() {
    local toolkit_dirname="$SHARED_MAKE_SH_DIRNAME/.."
    
    # Assume that everybody depends on CommandLineToolkit and generate package for it:
    make -f "${toolkit_dirname}/Makefile" -C "${toolkit_dirname}" generate
    
    swift run --package-path "${toolkit_dirname}/PackageGenerator/" package-gen "$PROJECT_DIR"
}

action___open() {
    __close_spm_package_in_xcode_saving_changes
    
    action___generate
    
    perform_inside_project open Package.swift
}

action___clean() {
    perform_inside_project rm -rf .build/
}

action___build() {
    action___generate
    local arch_options=$(__make_swift_build_arch_options "$@")
    perform_inside_project swift build $arch_options -c release -Xswiftc -Osize
}

action___build_debug() {
    action___generate
    local arch_options=$(__make_swift_build_arch_options "$@")
    perform_inside_project swift build $arch_options -c debug -Xswiftc -Onone
}

action___test() {
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

action___run_ci_tests() {
    export ON_CI=true
    export SHOULD_VERIFY_THAT_PACKAGE_CONTENTS_ARE_UNCHANGED=true
    action___test --enable-code-coverage -Xswiftc -DTEST
}
