/*
 * Copyright (c) Avito Tech LLC
 */

import Foundation

import CLTExtensions

public struct Credentials: Codable, Hashable {
    public var username: String
    public var password: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    public func asHTTPHeaderValue() throws -> String {
        try "\(username):\(password)".dataUsingUtf8().base64EncodedString()
    }
}
