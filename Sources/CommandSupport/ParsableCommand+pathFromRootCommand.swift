import ArgumentParser
import CLTExtensions

/// Error types for command path generation.
public enum ParsableCommandPathError: Error {
    case commandNotFoundInTree
}

extension ParsableCommand {

    /// Retrieves the command path from a specified root command.
    /// - Parameters:
    ///   - rootCommand: The root command type from which to start the path generation.
    /// - Throws: `ParsableCommandPathError.commandNotFoundInTree` if the target command path is not found within the specified command tree.
    /// - Returns: A string representing the command path.
    public static func path(fromRootCommand rootCommand: ParsableCommand.Type) throws -> String {
        try generateCommandPath(for: Self.self, in: rootCommand)
    }

    /// Recursively generates the command path for the specified target command.
    /// - Parameters:
    ///   - targetType: The type of the target command.
    ///   - command: The current command being processed.
    ///   - currentPath: The accumulated command path during the recursion.
    /// - Throws: `ParsableCommandPathError.commandNotFoundInTree` if the target command is not found within the command tree.
    /// - Returns: The path to the target command as a string.
    private static func generateCommandPath(
        for targetType: ParsableCommand.Type,
        in command: ParsableCommand.Type,
        currentPath: String = ""
    ) throws -> String {
        if command == targetType {
            return try currentPath.isEmpty
                ? command.configuration.commandName.unwrapOrThrow()
                : "\(currentPath) \(command.configuration.commandName.unwrapOrThrow())"
        }

        for subcommand in command.configuration.subcommands {
            let newPath = try currentPath.isEmpty
                ? command.configuration.commandName.unwrapOrThrow()
                : "\(currentPath) \(command.configuration.commandName.unwrapOrThrow())"
            if let subcommandPath = try? generateCommandPath(
                for: targetType,
                in: subcommand,
                currentPath: newPath
            ) {
                return subcommandPath
            }
        }

        throw ParsableCommandPathError.commandNotFoundInTree
    }
}
