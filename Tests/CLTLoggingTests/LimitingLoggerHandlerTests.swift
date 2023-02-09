/*
 * Copyright (c) Avito Tech LLC
 */

import CLTLogging
import CLTLoggingTestHelpers
import Foundation
import TestHelpers
import XCTest

final class LimitingLoggerHandlerTests: XCTestCase {
    private lazy var targetHandler = FakeLoggerHandle()
    private lazy var handler = LimitingLoggerHandler(
        maximumVerbosity: .warning,
        target: targetHandler
    )
    
    func test___higher_verbosity_entries___delivered_to_target() throws {
        let logEntry = LogEntryFixture(verbosity: .always).logEntry()
        
        handler.handle(logEntry: logEntry)
        
        assert {
            targetHandler.logEntries
        } equals: {
            [logEntry]
        }
    }
    
    func test___lower_verbosity_entries___ignored() throws {
        let logEntry = LogEntryFixture(verbosity: .trace).logEntry()
        
        handler.handle(logEntry: logEntry)
        
        assert {
            targetHandler.logEntries
        } equals: {
            []
        }
    }
}
