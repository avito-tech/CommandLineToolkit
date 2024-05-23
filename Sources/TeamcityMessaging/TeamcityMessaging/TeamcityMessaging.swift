import Dispatch
import Foundation

/// Facade for working with Teamcity service messages.
///
/// https://www.jetbrains.com/help/teamcity/service-messages.html
public protocol TeamcityMessaging {
    func block<T>(
        name: String,
        flowId: String?,
        body: () throws -> T
    ) rethrows -> T
    
    func block<T>(
        name: String,
        flowId: String?,
        body: () async throws -> T
    ) async rethrows -> T
}

extension TeamcityMessaging {
    public func block<T>(
        name: String,
        body: () throws -> T
    ) rethrows -> T {
        try block(
            name: name,
            flowId: nil,
            body: body
        )
    }
    
    public func block<T>(
        name: String,
        body: () async throws -> T
    ) async rethrows -> T {
        try await block(
            name: name,
            flowId: nil,
            body: body
        )
    }
}
