action___generate() {
    local toolkit_dirname="$SHARED_MAKE_SH_DIRNAME/.."
    
    # Assume that everybody depends on CommandLineToolkit and generate package for it:
    make -f "${toolkit_dirname}/Makefile" -C "${toolkit_dirname}" generate
    
    swift run --package-path "${toolkit_dirname}/PackageGenerator/" package-gen "$PROJECT_DIR"
}

action___open() {
	action___generate
	perform_inside_project open Package.swift
}

action___clean() {
	perform_inside_project rm -rf .build/
}

action___build() {
	action___generate
	perform_inside_project swift build --triple x86_64-apple-macosx11.0 -c release -Xswiftc -Osize
}

action___test() {
	action___generate
	perform_inside_project swift test --parallel
}

action___run_ci_tests() {
    export ON_CI=true
    export SHOULD_VERIFY_THAT_PACKAGE_CONTENTS_ARE_UNCHANGED=true
    action___test
}