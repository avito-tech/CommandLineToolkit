/// Can be used in tests:
///
/// ```
/// final class DiTests: XCTestCase {
///     func test() {
///         assertDoesNotThrow {
///             CommandDiValidator().validate(commandType: MyCommand.self)
///         }
///     }
/// }
/// ```
///

import ArgumentParser

public final class CommandDiValidator {
    public init() {
    }
    
    public func validate(commandType: ParsableCommand.Type) throws {
        // May contain DI resolves
        if let commandLogicProvider = try self.commandLogicProvider(commandType: commandType) {
            try validate(commandLogicProvider: commandLogicProvider)
        }
        
        // May contain DI resolves (can crash)
        _ = commandType.helpMessage()
        
        try commandType.configuration.subcommands.forEach {
            try validate(commandType: $0)
        }
    }
    
    private func commandLogicProvider(commandType: ParsableCommand.Type) throws -> CommandLogicProvider? {
        let command: ParsableCommand
        
        if let testableCommand = commandType as? TestableCommand.Type {
            command = try commandType.parse(
                testableCommand.testableCommandArguments()
            )
        } else {
            // Note: if your tests crash, use `TestableCommand`
            // (see `TestableCommand.swift` for docs)
            command = commandType.init()
        }
        
        return command as? CommandLogicProvider
    }
    
    private func validate(commandLogicProvider: CommandLogicProvider) throws {
        _ = try commandLogicProvider.commandLogic()
    }
}
