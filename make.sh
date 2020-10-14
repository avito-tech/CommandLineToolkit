#!/bin/bash

cd "$(dirname "$0")"

set -xueo pipefail

function generate_package() {
    swift "PackageGenerator.swift"
}

function open_xcodeproj() {
	generate_xcodeproj
	open *.xcodeproj
}

function generate_xcodeproj() {
	generate_package
	swift package generate-xcodeproj --enable-code-coverage
}

function clean() {
	rm -rf .build/
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
        run_tests_parallel
        ;;
    package)
        generate_package
        ;;
    generate)
        generate_xcodeproj
        ;;
    open)
    	open_xcodeproj
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
