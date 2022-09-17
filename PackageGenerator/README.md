# `package-gen`

This is a buildable binary which generates `Package.swift` based on source files.

This tool is useful for larger scale projects written using Swift Package Manager technology.

- Add `package.json` file into your repo root next to `Package.swift` you'd like to generate

- Describe your package in `package.json` - please see `PackageJsonTests` for examples

- Use `swift run package-gen /path/to/folder/with/package.json`

All external dependencies will be picked up from `package.json`, you'd list them manually.

All local modules, however, are going to be generated from the source files contents. `package-gen` will parse `import` statements from source files in order to determine the dependencies of local modules.

# Source Code Structure Advice

We find it difficult to keep sources in `Sources` and `Tests` folders. It is better to keep tests next to the source files they test.

`package-gen` tool supports a different source tree layout.

- Put your modules inside `Targets` folder, for example `Targets/ModuleName/`

- Each module may have additional modules inside `Target/ModuleName/` folder. They will inherit the main module name as prefix.

  - `Targets/ModuleName/Sources` - this will be a 'main' module, its name will be `ModuleName`, and this module can be imported as `import ModuleName`, it will be represented as `.target` in `Package.swift`
  
  - `Targets/ModuleName/Tests` - this will be a test module, its name will be `ModuleNameTests`, it will be represented as `.testTarget` in `Package.swift`
  
  - `Targets/ModuleName/Models` - this will be a auxilliary module, its name will be `ModuleNameModels`, and this module can be imported as `import ModuleNameModels`, it will be represented as `.target` in `Package.swift`

`package-gen` also supports a traditional `Sources/` and `Tests/` source files layout.
