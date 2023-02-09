/*
 * Copyright (c) Avito Tech LLC
 */

import AtomicModels
import CLTLoggingModels
import Foundation

public final class RedirectingLoggerHandler: LoggerHandler {
    private let target: AtomicValue<LoggerHandler>
    
    public init(
        target: LoggerHandler = NoOpLoggerHandler()
    ) {
        self.target = AtomicValue(target)
    }
    
    public func setTarget(_ newTarget: LoggerHandler) {
        target.set(newTarget)
    }
    
    public func handle(logEntry: LogEntry) {
        target.currentValue().handle(logEntry: logEntry)
    }
    
    public func tearDownLogging(timeout: TimeInterval) {
        target.currentValue().tearDownLogging(timeout: timeout)
    }
}
