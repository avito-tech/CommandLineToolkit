/// Can be used in tests:
///
/// ```
/// import XCTest
/// import TestHelpers
/// import CommandSupport
/// import <your module>
/// 
/// final class DiTests: XCTestCase {
///     func test() {
///         assertDoesNotThrow {
///             try CommandDiValidator().validate(commandType: MyCommand.self)
///         }
///     }
/// }
/// ```
///

import ArgumentParser

public final class CommandDiValidator {
    public init() {
    }
        
    public func validate(
        commandType: ParsableCommand.Type
    ) throws {
        // May contain DI resolves
        let commandLogicProviderOrNil = try self.commandLogicProvider(
            commandType: commandType
        )
        
        if let commandLogicProvider = commandLogicProviderOrNil {
            try validate(commandLogicProvider: commandLogicProvider)
        }
        
        // May contain DI resolves (can crash)
        _ = commandType.helpMessage()
        
        try commandType.configuration.subcommands.forEach {
            try validate(
                commandType: $0
            )
        }
    }
    
    private func commandLogicProvider(
        commandType: ParsableCommand.Type
    ) throws -> CommandLogicProvider? {
        try commandType.parseAsRoot(
            arguments(
                commandType: commandType
            )
        ) as? CommandLogicProvider
    }

    private func arguments(commandType: ParsableCommand.Type) -> [String] {
        if let testableCommand = commandType as? TestableCommand.Type {
            return testableCommand.testableCommandArguments()
        } else {
            return []
        }
    }
    
    private func validate(commandLogicProvider: CommandLogicProvider) throws {
        try wrapFunctionError(functionName: "commandLogic") {
            _ = try commandLogicProvider.commandLogic()
        }
    }
    
    private func wrapFunctionError<T>(
        functionName: String,
        body: () throws -> T
    ) throws -> T {
        try wrapError(
            message: "Caught error while trying to execute `\(functionName)`",
            body: body
        )
    }
    
    private struct Error: Swift.Error, CustomStringConvertible {
        let description: String
    }
    
    private func wrapError<T>(
        message: String,
        body: () throws -> T
    ) throws -> T {
        do {
            return try body()
        } catch {
            
            throw Error(description: "\(message): \(error)")
        }
    }
}
