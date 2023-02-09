/*
 * Copyright (c) Avito Tech LLC
 */

import Foundation
import CLTLogging
import CLTLoggingModels
import XCTest

final class NSLogLikeLogEntryTextFormatterTests: XCTestCase {
    func test___with_location_with_coordinates() {
        let formatter = NSLogLikeLogEntryTextFormatter(
            logLocation: true,
            logCoordinates: true
        )
        
        let entry = LogEntry(
            file: "file",
            line: 42,
            coordinates: [
                LogEntryCoordinate(name: "some"),
                LogEntryCoordinate(name: "coordinate", value: "value"),
            ],
            message: "message",
            timestamp: Date(),
            verbosity: .always
        )
        let text = formatter.format(logEntry: entry)
        
        let expectedTimestamp = NSLogLikeLogEntryTextFormatter.logDateFormatter.string(from: entry.timestamp)
        
        XCTAssertEqual(
            text,
            "[ALWAYS] \(expectedTimestamp) file:42 some coordinate:value: message"
        )
    }
    
    func test___without_location_without_coordinates() {
        let formatter = NSLogLikeLogEntryTextFormatter(
            logLocation: false,
            logCoordinates: false
        )
        
        let entry = LogEntry(
            file: "file",
            line: 42,
            coordinates: [
                LogEntryCoordinate(name: "some"),
                LogEntryCoordinate(name: "coordinate", value: "value"),
            ],
            message: "message",
            timestamp: Date(),
            verbosity: .always
        )
        let text = formatter.format(logEntry: entry)
        
        let expectedTimestamp = NSLogLikeLogEntryTextFormatter.logDateFormatter.string(from: entry.timestamp)
        
        XCTAssertEqual(
            text,
            "[ALWAYS] \(expectedTimestamp): message"
        )
    }
}
