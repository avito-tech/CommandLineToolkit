import Foundation
import CLTExtensions

public final class ProcessInfoCurrentExecutableProvider: CurrentExecutableProvider {
    private let processInfo: ProcessInfo
    
    public init(processInfo: ProcessInfo) {
        self.processInfo = processInfo
    }
    
    public func currentExecutablePath() throws -> String {
        try processInfo.arguments.first.unwrapOrThrow(
            message: "processInfo's arguments list is empty"
        )
    }
}
