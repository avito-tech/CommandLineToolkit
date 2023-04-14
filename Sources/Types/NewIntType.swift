import Foundation

open class NewIntType: ExpressibleByIntegerLiteral, Codable, Hashable, CustomStringConvertible, Comparable,
        CodingKeyRepresentable {
    public typealias IntegerLiteralType = Int

    public let value: Int

    public init(value: Int) {
        self.value = value
    }
    
    public required init(integerLiteral value: Int) {
        self.value = value
    }

    public var description: String {
        return "\(value)"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }

    public static func ==(left: NewIntType, right: NewIntType) -> Bool {
        return left.value == right.value
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(Int.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }

    @available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
    public required init?<T: CodingKey>(codingKey: T) {
        guard let value = Int(codingKey: codingKey) else { return nil }
        self.value = value
    }

    @available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
    public var codingKey: CodingKey {
        value.codingKey
    }
    
    public static func < (left: NewIntType, right: NewIntType) -> Bool {
        return left.value < right.value
    }
}
