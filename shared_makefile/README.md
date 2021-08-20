# Shared Makefile

## How to use

- Create symlink from Makefile from this folder to Makefile in your project's folder
- `make` will work out of the box with default actions like `generate`, `open` (see `default_actions.sh`
- Autocomplete will work in `bash` and `fish` (if you installed completion packages)
- To make it work in zsh, add this to `.zshrc`:

```
zstyle ':completion:*:make:*:targets' call-command true
zstyle ':completion:*:*:make:*' tag-order 'targets'
```

Note: to install completion, use this.

For bash: `brew install bash-completion`
For zsh: `brew install zsh-completions`
For fish: just install fish (`brew install fish`)

## Custom actions

Add `custom_actions.sh` to your project folder (where you put symlink to a Makefile).

If you want to use `make foo` add this to `custom_actions.sh`:

```
action___foo() {
    echo bar
}
```

Functions should be named "action" + 3 underscores + action name.

Available global variables:

- `REPO_ROOT` - where `.reporoot` file is located (you must have this)
- `PROJECT_DIR` - folder where your symlink to Makefile is located

Note that you can use functions from `actions_support.sh`, for example, to export a binary to specified folder. Example:

```
action___install() {
    action___build
    build_and_export_executable "avito-codegen" "$PROJECT_DIR"
}
```

There's also `utilities.sh` for more low level functions.

## How it works

- Makefile gets targets via calling `make.sh --project-dir <...> --targets`
- Target names are formed from all functions like `action___<target name>`.
- When Makefile runs target, a corresponding function is called.