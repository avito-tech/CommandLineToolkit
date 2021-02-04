import Foundation
import PathLib
import ProcessController
import ProcessControllerTestHelpers
import TestHelpers
import Tmp
import XCTest

final class LoggableProcessControllerProviderTests: XCTestCase {
    lazy var processControllerProvider = FakeProcessControllerProvider()
    lazy var tempFolder = assertDoesNotThrow { try TemporaryFolder() }
    
    func test() throws {
        let stdoutFilePath = try tempFolder.createFile(filename: "stdout")
        let stderrFilePath = try tempFolder.createFile(filename: "stderr")
        
        let loggableProvider = LoggableProcessControllerProvider(
            pathProvider: { _ -> (stdout: AbsolutePath, stderr: AbsolutePath) in
                (stdout: stdoutFilePath, stderr: stderrFilePath)
            },
            provider: processControllerProvider
        )
        
        let processController = try loggableProvider.createProcessController(
            subprocess: Subprocess(arguments: ["/usr/bin/env"])
        )
        let fakeProcessController: FakeProcessController = assertCast { processController }
        
        fakeProcessController.broadcastStdout(data: Data("stdout".utf8))
        fakeProcessController.broadcastStderr(data: Data("stderr".utf8))
        
        XCTAssertEqual(
            try String(contentsOfFile: stdoutFilePath.pathString),
            "stdout"
        )
        
        XCTAssertEqual(
            try String(contentsOfFile: stderrFilePath.pathString),
            "stderr"
        )
    }
}
