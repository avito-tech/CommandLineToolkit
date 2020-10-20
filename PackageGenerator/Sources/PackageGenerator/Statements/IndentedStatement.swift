import Foundation

public struct IndentedStatement {
    public let level: Int
    public let string: String
    
    public var statement: String {
        Array(repeating: " ", count: 4 * level) + string
    }
}
