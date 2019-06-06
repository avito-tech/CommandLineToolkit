# Avito Shared Utils

Swift package that provides some basic shareable utility classes.

## Developing

- `make open` to generate Xcode project and open it in Xcode
- `make test` to run all unit tests using SPM
- `make build` to build all products using SPM

## Timer

A GCD-based timer.

```swift
let timer = DispatchBasedTimer.startedTimer(repeating: .seconds(1), leeway: .seconds(1)) { [weak self] timer in
    guard let strongSelf = self else {
        timer.stop()
        return
    }
    strongSelf.handleTimerTick()
}
```

