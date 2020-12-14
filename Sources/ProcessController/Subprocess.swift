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

public struct Environment: ExpressibleByDictionaryLiteral, CustomStringConvertible {
    public let values: [String: String]
    
    public init(_ values: [String: String]) {
        self.values = values
    }
    
    public static var current: Environment {
        Environment(ProcessInfo.processInfo.environment)
    }
    
    public func merge(with values: [String: String]) -> Environment {
        var result = self.values
        result.merge(values) { _, new -> String in new }
        return Environment(result)
    }
    
    public var description: String {
        values.map { "\($0.key)=\($0.value)" }.joined(separator: " ")
    }
    
    // MARK: - ExpressibleByDictionaryLiteral
    
    public typealias Key = String
    public typealias Value = String
    public init(dictionaryLiteral elements: (String, String)...) {
        var values = [String: String]()
        for element in elements {
            values[element.0] = element.1
        }
        self.values = values
    }
}
