/*
 * Copyright (c) Avito Tech LLC
 */

import Foundation

public final class LoggableOptional<T>: CustomStringConvertible {
    private let value: T?
    private let nilReplacement: String
    
    public init(_ value: T?, nilReplacement: String = "nil") {
        self.value = value
        self.nilReplacement = nilReplacement
    }
    
    public var description: String {
        if let value = value {
            return "\(value)"
        }
        return nilReplacement
    }
}
