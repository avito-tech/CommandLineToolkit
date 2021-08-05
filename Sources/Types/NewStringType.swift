import Foundation

open class NewStringType: ExpressibleByStringLiteral, Codable, Hashable, CustomStringConvertible, CustomDebugStringConvertible, Comparable {
    public typealias StringLiteralType = String

    public let value: String
    
    public convenience init(_ value: String) {
        self.init(value: value)
    }

    public init(value: String) {
        self.value = value
    }

    public var description: String {
        value
    }
    
    public var debugDescription: String {
        return "\(type(of: self)): \(value)"
    }

    public required init(stringLiteral value: StringLiteralType) {
        self.value = value
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }

    public static func ==(left: NewStringType, right: NewStringType) -> Bool {
        return left.value == right.value
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
    
    public static func < (left: NewStringType, right: NewStringType) -> Bool {
        return left.value < right.value
    }
}
