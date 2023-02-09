/*
 * Copyright (c) Avito Tech LLC
 */

import DateProviderTestHelpers
import CLTLogging
import CLTLoggingModels
import Foundation
import TestHelpers
import Tmp
import XCTest

final class FileHandleLoggerHandlerTests: XCTestCase {
    lazy var tempFile = assertDoesNotThrow { try TemporaryFile(deleteOnDealloc: true) }
    
    lazy var loggerHandler = FileHandleLoggerHandler(
        dateProvider: DateProviderFixture(),
        fileHandle: tempFile.fileHandleForWriting,
        logEntryTextFormatter: SimpleLogEntryTextFormatter(),
        fileHandleShouldBeClosed: true,
        skipMetadataFlag: nil
    )
    
    func test___handling_coordinates___alters_message() throws {
        let logEntry = LogEntry(
            file: "file",
            line: 42,
            coordinates: [
                LogEntryCoordinate(name: "coordinate"),
                LogEntryCoordinate(name: "123"),
            ],
            message: "message",
            timestamp: Date(),
            verbosity: Verbosity.info
        )
        loggerHandler.handle(logEntry: logEntry)
        
        XCTAssertEqual(
            try tempFileContents(),
            SimpleLogEntryTextFormatter().format(logEntry: logEntry) + "\n"
        )
    }
    
    func test___handling_coordinates___alters_message___filters_out_context_key_coordinates() throws {
        let logEntry = LogEntry(
            file: "file",
            line: 42,
            coordinates: [
                LogEntryCoordinate(name: "coordinate"),
                LogEntryCoordinate(name: "123"),
                LogEntryCoordinate(name: ContextualLogger.ContextKeys.hostname.rawValue, value: "value"),
            ],
            message: "message",
            timestamp: Date(),
            verbosity: Verbosity.info
        )
        loggerHandler.handle(logEntry: logEntry)
        
        XCTAssertEqual(
            try tempFileContents(),
            SimpleLogEntryTextFormatter().format(
                logEntry: logEntry.with(
                    coordinates: [
                        LogEntryCoordinate(name: "coordinate"),
                        LogEntryCoordinate(name: "123"),
                    ]
                )
            ) + "\n"
        )
    }
    
    func test___non_closable_file___is_not_closed() throws {
        let fileHandler = FakeFileHandle()
        let loggerHandler = FileHandleLoggerHandler(
            dateProvider: DateProviderFixture(),
            fileHandle: fileHandler,
            logEntryTextFormatter: SimpleLogEntryTextFormatter(),
            fileHandleShouldBeClosed: false,
            skipMetadataFlag: nil
        )
        loggerHandler.tearDownLogging(timeout: 10)
        
        XCTAssertFalse(fileHandler.isClosed)
    }
    
    func test___closable_file___is_closed() throws {
        let fileHandler = FakeFileHandle()
        let loggerHandler = FileHandleLoggerHandler(
            dateProvider: DateProviderFixture(),
            fileHandle: fileHandler,
            logEntryTextFormatter: SimpleLogEntryTextFormatter(),
            fileHandleShouldBeClosed: true,
            skipMetadataFlag: nil
        )
        loggerHandler.tearDownLogging(timeout: 10)
        
        XCTAssertTrue(fileHandler.isClosed)
    }
    
    func test___closable_file___is_closed_only_once() throws {
        let fileHandler = FakeFileHandle()
        let loggerHandler = FileHandleLoggerHandler(
            dateProvider: DateProviderFixture(),
            fileHandle: fileHandler,
            logEntryTextFormatter: SimpleLogEntryTextFormatter(),
            fileHandleShouldBeClosed: true,
            skipMetadataFlag: nil
        )
        loggerHandler.tearDownLogging(timeout: 10)
        loggerHandler.tearDownLogging(timeout: 10)
        
        XCTAssertEqual(fileHandler.closeCounter, 1)
    }
    
    private func tempFileContents() throws -> String {
        return try String(contentsOf: tempFile.absolutePath.fileUrl)
    }
}
