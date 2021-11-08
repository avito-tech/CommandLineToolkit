import Foundation

final class NumericStorage {
    var bytes = Data()
    var parsedNumber: NSNumber?
    
    init(_ initialBytes: Data) {
        bytes = initialBytes
    }
}

enum ParsingContext: CustomStringConvertible {
    case root
    case inObject(key: String?, storage: NSMutableDictionary)
    case inArray(key: String?, storage: NSMutableArray)
    case inKey(NSMutableData)
    case inValue(key: String)
    case inStringObject(storage: NSMutableData)
    case inStringValue(key: String?, storage: NSMutableData)
    case inNullValue(key: String?)
    case inTrueValue(key: String?)
    case inFalseValue(key: String?)
    case inNumericValue(key: String?, storage: NumericStorage)
    
    var description: String {
        switch self {
        case .root:
            return "root"
        case let .inObject(key, storage):
            return "inObject for key '\(key ?? "null")': '\(storage)'"
        case let .inArray(key, storage):
            return "inArray for key '\(key ?? "null")': '\(storage)'"
        case let .inKey(key):
            return "inKey \(key)"
        case let .inValue(key):
            return "inValue for key '\(key)'"
        case let .inStringValue(key, storage):
            return "inStringValue for key '\(key ?? "null")': '\(storage)'"
        case let .inStringObject(storage):
            return "inStringObject: '\(storage)'"
        case let .inNullValue(key):
            return "inNullValue for key '\(key ?? "null")'"
        case let .inTrueValue(key):
            return "inTrueValue for key '\(key ?? "null")'"
        case let .inFalseValue(key):
            return "inFalseValue for key '\(key ?? "null")'"
        case let .inNumericValue(key, storage):
            return "inNumericValue for key '\(key ?? "null")': '\(storage)'"
        }
    }
}
