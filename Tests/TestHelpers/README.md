#  TestHelpers

```swift

// Check for true
assertTrue {
    try somethingThat() == true
}

// Check for false
assertFalse {
    try somethingThat() == false
}

// Casting
let string: String = assertCast { 
    try getSetOfAnyObjectsFromSomewhere() as Set<Any> 
}

// Equality
assert {
    try getSomething()
} equals: {
    try getSomethingElse()
}

// Nil
let string: String = assertNotNil { someArrayOfStrings.first }

// Throws
assertThrows {
    try somethingThatShouldThrow()
}

// Does not throw
let value: String = assertDoesNotThrow {
    try getArrayOfStringsFromSomethingThatMayThrow()
}

// Failing Test
failTest("Failing test because I want to")

// ErrorForTestingPurposes - when you need some Error to throw
throw ErrorForTestingPurposes(text: "Some error for testing purposes")

// Async to sync
let int = runSyncronously { completion in
    DispatchQueue.main.async {
        completion(42)
    }
}
assert { int } equals: { 42 }

```
