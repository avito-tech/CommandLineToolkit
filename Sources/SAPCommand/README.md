#  Swift Argument Parser Command with DI

This module provides a base command which allows to inject DI. It uses MixboxDi.

Usage:

1. Create a DI registerer which will fill DI with objects:

```swift

import SAPCommand

public final class CommonDependenciesRegistrar: SAPCommandDi {
    public init() {}
    
    public func register(dependencyRegisterer di: DependencyRegisterer) {
        di.register(type: SomeType.self) { _ in
            SomeTypeImpl()
        }
        di.register(type: AnotherType.self) { di in
            AnotherTypeImpl(
                someType: try di.resolve()
            )
        }
        // ...
    }
}
```

2. It is convenient to introduce a type alias for your command like this:

```swift

import SAPCommand

public typealias MyCommandWithDi = SAPCommandWithDi<CommonDependenciesRegistrar>
```

3. From now derive from `MyCommandWithDi` instead of `ParsableCommand`. It will have `di` property for your needs.

```swift

import ArgumentParser
import SAPCommand

public final class HelloCommand: MyCommandWithDi {
    public static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "hello"
        )
    }
    
    public func commandLogic() throws -> SAPCommandLogic {
        return HelloCommandLogic(
            anotherType: try di.resolve()       // di is part of MyCommandWithDi
        )
    }
}

public final class HelloCommandLogic: SAPCommandLogic {
    private let anotherType: AnotherType
    
    public init(
        anotherType: AnotherType
    ) {
        self.anotherType = anotherType
    }
    
    public func run() throws {
        print("This is anotherType instance which was taken from DI:", anotherType)
    }
}
```

4. If, for any reasons, you will need to instanciate DI from outside your commands:

```swift

let di = BaseSAPCommandWithDi<AiCommandsDependencies>.makeDi()

```
