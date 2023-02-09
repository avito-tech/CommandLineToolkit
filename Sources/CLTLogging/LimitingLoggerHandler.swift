/*
 * Copyright (c) Avito Tech LLC
 */

import CLTLoggingModels
import Foundation

public final class LimitingLoggerHandler: LoggerHandler {
    private let maximumVerbosity: Verbosity
    private let target: LoggerHandler
    
    public init(
        maximumVerbosity: Verbosity,
        target: LoggerHandler
    ) {
        self.maximumVerbosity = maximumVerbosity
        self.target = target
    }
    
    public func handle(logEntry: LogEntry) {
        guard maximumVerbosity.allowsLoggingWthVerbosity(logEntry.verbosity) else { return }
        
        target.handle(logEntry: logEntry)
    }
    
    public func tearDownLogging(timeout: TimeInterval) {
        target.tearDownLogging(timeout: timeout)
    }
}
