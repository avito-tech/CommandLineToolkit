import Foundation

public extension String {
    enum StringError: Error, CustomStringConvertible {
        case notUtf8(data: Data)
        
        public var description: String {
            switch self {
            case let .notUtf8(data):
                return "Bytes \(data.base64EncodedString()) are not utf8"
            }
        }
    }
    
    init(utf8Data: Data) throws {
        guard let string = String(data: utf8Data, encoding: .utf8) else {
            throw StringError.notUtf8(data: utf8Data)
        }
        self = string
    }
}
