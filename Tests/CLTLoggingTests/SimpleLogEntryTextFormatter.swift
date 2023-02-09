/*
 * Copyright (c) Avito Tech LLC
 */

import Foundation
import CLTLogging
import CLTLoggingModels

final class SimpleLogEntryTextFormatter: LogEntryTextFormatter {
    func format(logEntry: LogEntry) -> String {
        var result = ""
        result += "\(logEntry.timestamp)"
        
        if !logEntry.coordinates.isEmpty {
            result += " " + logEntry.coordinates.map { $0.stringValue }.joined(separator: " ")
        }
        
        result += ":"
        result += " \(logEntry.message)"
        
        return result
    }
}
