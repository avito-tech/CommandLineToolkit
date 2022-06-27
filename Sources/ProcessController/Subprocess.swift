import Foundation
import PathLib

public class Subprocess: CustomStringConvertible {
    public let arguments: [SubprocessArgument]
    public let environment: Environment
    public let automaticManagement: AutomaticManagement
    public let workingDirectory: AbsolutePath
    
    public init(
        arguments: [SubprocessArgument],
        environment: Environment = [:],
        automaticManagement: AutomaticManagement = .noManagement,
        workingDirectory: AbsolutePath = FileManager.default.currentAbsolutePath
    ) {
        self.arguments = arguments
        self.environment = environment
        self.automaticManagement = automaticManagement
        self.workingDirectory = workingDirectory
    }
    
    public var description: String {
        let argumentsDescription = arguments.map { "\"\($0)\"" }.joined(separator: " ")
        return "<\(type(of: self)) \(environment) \(argumentsDescription), working dir: \(workingDirectory), automatic management: \(automaticManagement)>"
    }
}
