import Foundation

public extension String {
    enum StringError: Error, CustomStringConvertible {
        case notUtf8Data(data: Data)
        case notUtf8String(string: String)
        
        public var description: String {
            switch self {
            case let .notUtf8Data(data):
                return "Bytes \(data.base64EncodedString()) are not utf8"
            case let .notUtf8String(string):
                return "Failed to convert string \"\(string)\" to UTF-8 data"
            }
        }
    }
    
    init(utf8Data: Data) throws {
        guard let string = String(data: utf8Data, encoding: .utf8) else {
            throw StringError.notUtf8Data(data: utf8Data)
        }
        self = string
    }
    
    func dataUsingUtf8() throws -> Data {
        guard let data = self.data(using: .utf8) else {
            throw StringError.notUtf8String(string: self)
        }
        return data
    }
}
