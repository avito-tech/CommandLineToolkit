import Foundation

public enum JSONReaderError: Error, CustomStringConvertible {
    case unexpectedCharacter(UInt8)
    case unexpectedCharacters([UInt8], expected: [UInt8])
    case streamHasNoData
    case streamEndedAtRootContext
    case invalidStringData(Data)
    case invalidNumberValue(Data)
    
    public var description: String {
        switch self {
        case let .unexpectedCharacter(byte):
            return "Stream contains unexpected character: \(byte) ('\(Character(UnicodeScalar(byte)))')"
        case let .unexpectedCharacters(bytes, expected):
            return "Stream contains unexpected set of characters: \(bytes) (\(bytes.map { Character(UnicodeScalar($0)) }); expected to have these characters: \(expected) (\(expected.map { Character(UnicodeScalar($0)) })"
        case .streamHasNoData:
            return "Stream has no data"
        case .streamEndedAtRootContext:
            return "Stream ended at root context"
        case let .invalidStringData(data):
            return "Unable to get UTF8 string from data: \(data)"
        case let .invalidNumberValue(data):
            return "Unable to get number from data: \(data)"
        }
    }
}
