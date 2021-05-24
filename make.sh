#!/bin/bash

cd "$(dirname "$0")"

set -xueo pipefail

function generate_package() {
    swift run --package-path "$(pwd)/PackageGenerator/" package-gen $(pwd)
}

function open_package() {
    generate_package
	open Package.swift
}

function clean() {
	rm -rf .build/
    rm -rf .swiftpm/
    rm -rf *.xcodeproj
}

function build() {
	generate_package
	swift build
}

function run_tests_parallel() {
	generate_package
	swift test --parallel
}

case "$1" in
    run_ci_tests)
        export ON_CI=true
        export SHOULD_VERIFY_THAT_PACKAGE_CONTENTS_ARE_UNCHANGED=true
        run_tests_parallel
        ;;
    package)
        generate_package
        ;;
    open)
    	open_package
    	;;
    test)
        run_tests_parallel
        ;;
    build)
    	build
    	;;
    clean)
    	clean
    	;;
esac
