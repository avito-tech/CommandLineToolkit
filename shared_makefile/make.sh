#!/bin/bash

set -ueo pipefail

python_realpath() {
  python -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$1"
}

if [ "${DEBUG:-0}" != "0" ]; then
    set -x
fi

SHARED_MAKE_SH_DIRNAME=$(python_realpath "$(dirname "$0")")

source "${SHARED_MAKE_SH_DIRNAME}/actions_support.sh"
source "${SHARED_MAKE_SH_DIRNAME}/calling_actions.sh"
source "${SHARED_MAKE_SH_DIRNAME}/default_actions.sh"
source "${SHARED_MAKE_SH_DIRNAME}/utilities.sh"

ignore_errors_for_projects_without_shared_make=false

__validate_project() {
    ! [ -z "$PROJECT_DIR" ] || __fatal_error "Project is not defined, use --project-dir <dir> option to define project dir"
    
    local shared_makefile
    shared_makefile=$(python_realpath "$SHARED_MAKE_SH_DIRNAME/Makefile")
    
    local project_makefile
    project_makefile=$(python_realpath "$PROJECT_DIR/Makefile")
    
    [ "$project_makefile" == "$shared_makefile" ] || $ignore_errors_for_projects_without_shared_make || __fatal_error "Project $PROJECT_DIR is not using shared make"
}


main() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --project-dir)
                PROJECT_DIR=$2
                __validate_project
                # Can overwrite existing actions
                __load_custom_actions "$PROJECT_DIR"
                shift
                shift
                ;;
            --targets)
                __validate_project
                __all_actions
                shift
                ;;
            --ignore-errors-for-projects-without-shared-make)
                ignore_errors_for_projects_without_shared_make=true
                shift
                ;;
            *)
                __validate_project
                __execute_action "$PROJECT_DIR" "$@"
                return $?
                ;;
        esac
    done
}

main "$@"
