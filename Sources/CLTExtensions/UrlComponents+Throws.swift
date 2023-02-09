/*
 * Copyright (c) Avito Tech LLC
 */

import Foundation

public struct CannotBuildUrl: Error, CustomStringConvertible {
    public let components: URLComponents
    
    public var description: String {
        "Cannot build URL from components: \(components)"
    }
}

public struct CannotBuildFromString: Error, CustomStringConvertible {
    public let string: String
    public var description: String { "Cannot build components from string: '\(string)'" }
}

public struct CannotBuildFromUrl: Error, CustomStringConvertible {
    public let url: URL
    public var description: String { "Cannot build components from URL: \(url)" }
}

extension URLComponents {
    public static func createFromUrl(_ url: URL) throws -> URLComponents {
        guard let result = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw CannotBuildFromUrl(url: url)
        }
        return result
    }
    
    public static func createFromString(_ string: String) throws -> URLComponents {
        guard let result = URLComponents(string: string) else {
            throw CannotBuildFromString(string: string)
        }
        return result
    }
    
    public func createUrl() throws -> URL {
        guard let url = self.url else {
            throw CannotBuildUrl(components: self)
        }
        return url
    }
    
    public func createStringUrl() throws -> String {
        guard let string = self.string else {
            throw CannotBuildUrl(components: self)
        }
        return string
    }
}
