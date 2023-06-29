import Logging

struct LogComponentState: Hashable {
    let level: Logger.Level
    let message: Logger.Message
    let metadata: Logger.Metadata
    let source: String
    let file: String
    let function: String
    let line: UInt
}

extension Logger.Message: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}

extension Logger.MetadataValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .string(let string):
            hasher.combine("string")
            hasher.combine(string)
        case .stringConvertible(let customStringConvertible):
            hasher.combine("stringConvertible")
            hasher.combine(customStringConvertible.description)
        case .dictionary(let metadata):
            hasher.combine("dictionary")
            hasher.combine(metadata)
        case .array(let array):
            hasher.combine("array")
            hasher.combine(array)
        }
    }
}
