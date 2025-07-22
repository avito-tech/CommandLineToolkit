import Foundation

public enum TraceMetadataValue {
    case none
    case int(Int)
    case double(Double)
    case bool(Bool)
    case string(String)
    case array([TraceMetadataValue])
    case object([String: TraceMetadataValue])
}

extension TraceMetadataValue: Encodable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .none:
            try container.encodeNil()
        case let .int(value):
            try container.encode(value)
        case let .double(value):
            try container.encode(value)
        case let .bool(value):
            try container.encode(value)
        case let .string(value):
            try container.encode(value)
        case let .array(value):
            try container.encode(value)
        case let .object(value):
            try container.encode(value)
        }
    }
}

extension TraceMetadataValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension TraceMetadataValue: ExpressibleByStringInterpolation {
    public init(stringInterpolation: DefaultStringInterpolation) {
        self = .string(stringInterpolation.description)
    }
}

extension TraceMetadataValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .none
    }
}

extension TraceMetadataValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension TraceMetadataValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension TraceMetadataValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension TraceMetadataValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, TraceMetadataValue)...) {
        self = .object(.init(uniqueKeysWithValues: elements))
    }
}

extension TraceMetadataValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: TraceMetadataValue...) {
        self = .array(elements)
    }
}
