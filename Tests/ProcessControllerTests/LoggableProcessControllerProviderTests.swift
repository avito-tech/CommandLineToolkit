import Foundation
import PathLib
import ProcessController
import ProcessControllerTestHelpers
import TestHelpers
import Tmp
import XCTest

final class LoggableProcessControllerProviderTests: XCTestCase {
    lazy var processControllerProvider = FakeProcessControllerProvider()
    
    func test() throws {
        let stdoutFile = try TemporaryFile()
        let stderrFile = try TemporaryFile()
        
        let loggableProvider = LoggableProcessControllerProvider(
            filesProvider: { _ -> (stdout: TemporaryFile, stderr: TemporaryFile) in
                (stdout: stdoutFile, stderr: stderrFile)
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
            try String(contentsOfFile: stdoutFile.absolutePath.pathString),
            "stdout"
        )
        
        XCTAssertEqual(
            try String(contentsOfFile: stderrFile.absolutePath.pathString),
            "stderr"
        )
    }
}
