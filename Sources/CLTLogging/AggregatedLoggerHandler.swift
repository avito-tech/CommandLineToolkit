/*
 * Copyright (c) Avito Tech LLC
 */

import Dispatch
import CLTLoggingModels
import Foundation

public final class AggregatedLoggerHandler: LoggerHandler {
    private var handlers: [LoggerHandler]
    private let syncQueue = DispatchQueue(label: "AggregatedLoggerHandler.syncQueue")
    
    public init(handlers: [LoggerHandler]) {
        self.handlers = handlers
    }
    
    public func handle(logEntry: LogEntry) {
        for handler in allHandlers_safe {
            handler.handle(logEntry: logEntry)
        }
    }
    
    public func append(handler: LoggerHandler) {
        syncQueue.sync {
            handlers.append(handler)
        }
    }
    
    private var allHandlers_safe: [LoggerHandler] {
        return syncQueue.sync { handlers }
    }
    
    public func tearDownLogging(timeout: TimeInterval) {
        for handler in allHandlers_safe {
            syncQueue.async {
                handler.tearDownLogging(timeout: timeout)
            }
        }
    }
}
