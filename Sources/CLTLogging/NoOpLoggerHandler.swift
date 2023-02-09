/*
 * Copyright (c) Avito Tech LLC
 */

import CLTLoggingModels
import Foundation

public final class NoOpLoggerHandler: LoggerHandler {
    public init() {}
    
    public func handle(logEntry: LogEntry) {
        
    }
    
    public func tearDownLogging(timeout: TimeInterval) {
        
    }
}
