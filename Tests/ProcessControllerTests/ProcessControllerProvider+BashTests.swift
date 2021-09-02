import DateProvider
import FileSystem
import Foundation
import ProcessController
import TestHelpers
import Tmp
import XCTest

final class ProcessControllerProviderBashTests: XCTestCase {
    lazy var dateProvider = SystemDateProvider()
    lazy var tempFolder = assertDoesNotThrow { try TemporaryFolder() }
    
    lazy var processControllerProvider = DefaultProcessControllerProvider(
        dateProvider: dateProvider,
        filePropertiesProvider: FilePropertiesProviderImpl()
    )
    
    func test__stdout() throws {
        try tempFolder.createFile(filename: "hello")
        
        let capturedOutput = CapturedOutputStreams()
        try processControllerProvider.bash(
            "ls",
            currentWorkingDirectory: tempFolder.absolutePath,
            outputStreaming: capturedOutput.outputStreaming
        )
        XCTAssertEqual(
            capturedOutput.stdoutSting,
            "hello\n"
        )
    }
    
    func test__stderr() throws {
        let uniqueString = ProcessInfo.processInfo.globallyUniqueString
        let capturedOutput = CapturedOutputStreams()
        assertThrows {
            try processControllerProvider.bash(
                "ls \(uniqueString)",
                currentWorkingDirectory: tempFolder.absolutePath,
                outputStreaming: capturedOutput.outputStreaming
            )
        }
        XCTAssertEqual(
            capturedOutput.stderrSting,
            "ls: \(uniqueString): No such file or directory\n"
        )
    }
}
