project_makefile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
project_dir := $(shell dirname "$(project_makefile_path)")
shared_makefile_path := $(shell readlink "$(project_makefile_path)")
shared_makefile_dir := $(shell dirname "$(shared_makefile_path)")
shared_make_sh_path := "$(shared_makefile_dir)/make.sh"

targets := $(shell "$(shared_make_sh_path)" --project-dir "$(project_dir)" --targets)

$(targets):
	bash "${shared_make_sh_path}" --project-dir "${project_dir}" $@
.PHONY: $(targets)