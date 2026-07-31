import DateProvider
import FileSystem
import Foundation
import TestHelpers
import Tmp
import XCTest
@testable import ProcessController

final class ProcessControllerProviderBashTests: XCTestCase {
    lazy var dateProvider = SystemDateProvider()
    lazy var tempFolder = assertDoesNotThrow { try TemporaryFolder() }
    
    lazy var processControllerProvider = DefaultProcessControllerProvider(
        dateProvider: dateProvider,
        filePropertiesProvider: FilePropertiesProviderImpl()
    )
    
    func test__stdout() async throws {
        try tempFolder.createFile(filename: "hello")
        
        let capturedOutput = CapturedOutputStreams()
        try await processControllerProvider.subprocessAsync(
            arguments: ["/bin/ls"],
            currentWorkingDirectory: tempFolder.absolutePath,
            outputStreaming: capturedOutput.outputStreaming
        )
        XCTAssertEqual(
            capturedOutput.stdoutString,
            "hello\n"
        )
    }
    
    func test__stderr() async throws {
        let uniqueString = ProcessInfo.processInfo.globallyUniqueString
        let capturedOutput = CapturedOutputStreams()
        await assertThrows {
            try await processControllerProvider.subprocessAsync(
                arguments: ["/bin/ls", uniqueString],
                currentWorkingDirectory: tempFolder.absolutePath,
                outputStreaming: capturedOutput.outputStreaming
            )
        }
        XCTAssertEqual(
            capturedOutput.stderrString,
            "ls: \(uniqueString): No such file or directory\n"
        )
    }

    func test__failureReplay__capturesOnlyStderr() {
        var replayedData = Data()
        var replayedStatus: Int32?

        let outputStreaming = OutputStreaming.failureReplay(
            capture: .stderr,
            maxBufferedBytes: 1_024,
            ignoreNonZeroStatusCode: false
        ) { data, _, status in
            replayedData = data
            replayedStatus = status
        }

        outputStreaming.stdout(Data("stdout".utf8))
        outputStreaming.stderr(Data("stderr".utf8))
        outputStreaming.finish(1, false)

        XCTAssertEqual(String(decoding: replayedData, as: UTF8.self), "stderr")
        XCTAssertEqual(replayedStatus, 1)
    }

    func test__failureReplay__doesNotReplaySuccessfulProcessOutput() {
        var replayCount = 0

        let outputStreaming = OutputStreaming.failureReplay(
            capture: .stdoutAndStderr,
            maxBufferedBytes: 1_024,
            ignoreNonZeroStatusCode: false
        ) { _, _, _ in
            replayCount += 1
        }

        outputStreaming.stdout(Data("stdout".utf8))
        outputStreaming.stderr(Data("stderr".utf8))
        outputStreaming.finish(0, false)

        XCTAssertEqual(replayCount, 0)
    }

    func test__failureReplay__capturesStdoutAndStderrInDeliveryOrder() {
        var replayedData = Data()

        let outputStreaming = OutputStreaming.failureReplay(
            capture: .stdoutAndStderr,
            maxBufferedBytes: 1_024,
            ignoreNonZeroStatusCode: false
        ) { data, _, _ in
            replayedData = data
        }

        outputStreaming.stdout(Data("stdout".utf8))
        outputStreaming.stderr(Data("stderr".utf8))
        outputStreaming.finish(1, false)

        XCTAssertEqual(String(decoding: replayedData, as: UTF8.self), "stdoutstderr")
    }

    func test__failureReplay__keepsNewestBytesWithinLimit() {
        var replayedData = Data()
        var wasTruncated = false

        let outputStreaming = OutputStreaming.failureReplay(
            capture: .stderr,
            maxBufferedBytes: 5,
            ignoreNonZeroStatusCode: false
        ) { data, truncated, _ in
            replayedData = data
            wasTruncated = truncated
        }

        outputStreaming.stderr(Data("123".utf8))
        outputStreaming.stderr(Data("456".utf8))
        outputStreaming.finish(1, false)

        XCTAssertEqual(String(decoding: replayedData, as: UTF8.self), "23456")
        XCTAssertTrue(wasTruncated)
    }

    func test__outputStreaming__finishesAfterPipesAreDrained() async throws {
        let lock = NSLock()
        var stdout = Data()
        var stdoutAtFinish = Data()

        let outputStreaming = OutputStreaming { data in
            lock.lock()
            stdout.append(data)
            lock.unlock()
        } stderr: { _ in
        } finish: { _, _ in
            lock.lock()
            stdoutAtFinish = stdout
            lock.unlock()
        }

        try await processControllerProvider.subprocessAsync(
            arguments: ["/bin/echo", "finished"],
            outputStreaming: outputStreaming
        )

        XCTAssertEqual(String(decoding: stdout, as: UTF8.self), "finished\n")
        XCTAssertEqual(stdoutAtFinish, stdout)
    }
}
