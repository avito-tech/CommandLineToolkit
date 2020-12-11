#  UserDefaultsLib

Provides a little DSL to work with `NSUserDefaults` to allow type checking.

Since UserDefaults accepts only property list objects, this library adopts `PlistLib` APIs.

Simple example:

```swift

// create
let defaults = try SystemDefaults(suiteName: "com.domain.name")

// read
var numbers = try defaults.entryForKey("arrayOfNumbers").toTypedArray(Int.self)

numbers.append(numbers.count)

// update
defaults.set(
    entry: .array(numbers.map { .number($0) }),
    key: "arrayOfNumbers"
)

```
