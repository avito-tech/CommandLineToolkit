#!/bin/bash

set -ueo pipefail

if [ "${DEBUG:-0}" != "0" ]; then
    set -x
fi

SHARED_MAKE_SH_DIRNAME=$(realpath "$(dirname "$0")")

source "${SHARED_MAKE_SH_DIRNAME}/actions_support.sh"
source "${SHARED_MAKE_SH_DIRNAME}/calling_actions.sh"
source "${SHARED_MAKE_SH_DIRNAME}/default_actions.sh"
source "${SHARED_MAKE_SH_DIRNAME}/utilities.sh"

main() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --project-dir)
                PROJECT_DIR=$2
                # Can overwrite existing actions
                __load_custom_actions "$PROJECT_DIR"
                shift
                shift
                ;;
            --targets)
                __all_actions
                shift
                ;;
            *)
                __execute_action "$PROJECT_DIR" "$@"
                return $?
                ;;
        esac
    done
}

main "$@"
