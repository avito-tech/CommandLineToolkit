/*
 * Copyright (c) Avito Tech LLC
 */

import Foundation

public enum HttpAuthorizationScheme: Codable, Hashable {
    case basic(credentials: Credentials)
    case bearer(token: String)
    case apiKey(token: String)

    public func httpHeaderValue() throws -> String {
        switch self {
        case let .basic(credentials):
            return "Basic \(try credentials.asHTTPHeaderValue())"
        case let .bearer(token):
            return "Bearer \(token)"
        case let .apiKey(token):
            return "ApiKey \(token)"
        }
    }
}
