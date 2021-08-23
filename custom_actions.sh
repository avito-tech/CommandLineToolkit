# Default action makes release build, but it doesn't work with test helpers.
action___build() {
    perform_inside_project swift build
}

action___generate() {
    swift run --package-path "$PROJECT_DIR/PackageGenerator/" package-gen "$PROJECT_DIR"
}