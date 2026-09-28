import Foundation
import FileSystemTestHelpers
import PathLib
import XCTest
@testable import FileSystem

final class FileSystemEntrySequenceTests: XCTestCase {
    func test_creationAndIteratorAreLazyAndEachIteratorSeesFreshTree() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let sequence = FileSystemEntrySequence.local(at: AbsolutePath(root.path), traversal: .recursive, descendingInto: { _ in true })
        var iterator = sequence.makeAsyncIterator()
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try Data([1, 2]).write(to: root.appendingPathComponent("file"))
        try FileManager.default.setAttributes([.modificationDate: Date(timeIntervalSince1970: 1000.125)], ofItemAtPath: root.path + "/file")
        var first: [FileSystemEntry] = []
        while let entry = try await iterator.next() { first.append(entry) }
        XCTAssertEqual(Set(first.map { $0.path.lastComponent }), [root.lastPathComponent, "file"])
        try Data().write(to: root.appendingPathComponent("added"))
        var second: [FileSystemEntry] = []
        for try await entry in sequence { second.append(entry) }
        XCTAssertEqual(second.count, 3)
        let file = try XCTUnwrap(first.first { $0.path.lastComponent == "file" })
        XCTAssertEqual(file.metadata.size, 2)
        XCTAssertEqual(file.metadata.kind, .regularFile)
        XCTAssertEqual(file.metadata.modificationTimeNanoseconds, 1_000_125_000_000)
    }

    func test_prunesBeforeReadingDirectoryAndNeverFollowsLinks() async throws {
        let root = try temporaryRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        let skipped = root.appendingPathComponent("skipped")
        try FileManager.default.createDirectory(at: skipped, withIntermediateDirectories: true)
        try Data().write(to: skipped.appendingPathComponent("hidden"))
        try FileManager.default.createSymbolicLink(atPath: root.path + "/cycle", withDestinationPath: root.path)
        try FileManager.default.createSymbolicLink(atPath: root.path + "/broken", withDestinationPath: root.path + "/missing")
        var entries: [FileSystemEntry] = []
        for try await entry in FileSystemEntrySequence.local(at: AbsolutePath(root.path), traversal: .recursive, descendingInto: { $0.path.lastComponent != "skipped" }) {
            entries.append(entry)
        }
        XCTAssertEqual(Set(entries.map { $0.path.lastComponent }), [root.lastPathComponent, "skipped", "cycle", "broken"])
        XCTAssertEqual(entries.filter { $0.metadata.kind == .symbolicLink }.count, 2)
    }

    func test_missingRootThrowsWithPath() async throws {
        let path = AbsolutePath("/tmp/\(UUID().uuidString)/missing")
        var iterator = FileSystemEntrySequence.local(at: path, traversal: .recursive, descendingInto: { _ in true }).makeAsyncIterator()
        do {
            _ = try await iterator.next()
            XCTFail("Expected missing root error")
        } catch {
            XCTAssertEqual((error as NSError).userInfo[NSFilePathErrorKey] as? String, path.pathString)
        }
    }

    func test_cancelledConsumerDoesNotReadMissingRoot() async throws {
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            var iterator = FileSystemEntrySequence.local(at: AbsolutePath("/tmp/\(UUID().uuidString)/missing"), traversal: .recursive, descendingInto: { _ in true }).makeAsyncIterator()
            return try await iterator.next()
        }
        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch is CancellationError {} catch { XCTFail("Unexpected error: \(error)") }
    }

    func test_shallowTraversalIncludesOnlyImmediateChildren() async throws {
        let root = try temporaryRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(atPath: root.path + "/directory", withIntermediateDirectories: true)
        try Data().write(to: URL(fileURLWithPath: root.path + "/directory/file"))
        var names: [String] = []
        for try await entry in FileSystemEntrySequence.local(at: AbsolutePath(root.path), traversal: .shallow, descendingInto: { _ in true }) {
            names.append(entry.path.lastComponent)
        }
        XCTAssertEqual(Set(names), [root.lastPathComponent, "directory"])
    }

    func test_consumesBoundedBatchesAndDoesNotReadTheRestAfterBreak() async throws {
        let reads = ReadCounter()
        let root = AbsolutePath("/virtual")
        let sequence = FileSystemEntrySequence {
            FileTreeCursor(
                root: root,
                traversal: .recursive,
                descendingInto: { _ in true },
                metadata: { path in
                    reads.increment()
                    return FilePropertiesSnapshot(kind: path == root.pathString ? .directory : .regularFile, modificationDate: .distantPast, size: 0)
                },
                children: { _, _ in (0..<1000).map(String.init) }
            )
        }
        for try await _ in sequence { break }
        let afterBreak = reads.value
        XCTAssertGreaterThan(afterBreak, 1)
        XCTAssertLessThan(afterBreak, 1001)
        // No detached producer: another walk does not cause the abandoned one
        // to resume or consume additional entries.
        for try await _ in sequence { break }
        XCTAssertEqual(reads.value, afterBreak * 2)
    }

    func test_virtualFilesystemUsesItsOwnEntriesAndLinkMetadata() async throws {
        let root = AbsolutePath("/not-on-the-host/virtual")
        let fake = FakeFileSystem(rootPath: root)
        fake.propertiesProvider = { path in
            let properties = FakeFilePropertiesContainer()
            properties.isDirectory = path == root
            properties.isRegularFile = path != root
            properties.isSymbolicLink = path.lastComponent == "broken"
            properties.isBrokenSymbolicLink = properties.isSymbolicLink
            return properties
        }
        fake.fakeContentEnumerator = { args in
            FakeFileSystemEnumerator(path: args.path, items: [root.appending("file"), root.appending("broken")])
        }
        var entries: [FileSystemEntry] = []
        for try await entry in fake.entries(at: root) { entries.append(entry) }
        XCTAssertEqual(entries.map { $0.path.lastComponent }, ["virtual", "file", "broken"])
        XCTAssertEqual(entries.last?.metadata.kind, .symbolicLink)
    }

    func test_cancellationDuringBatchStopsBetweenFilesystemOperations() async throws {
        let started = expectation(description: "Blocking metadata read started")
        let releaseRead = DispatchSemaphore(value: 0)
        let reads = ReadCounter()
        let sequence = FileSystemEntrySequence {
            FileTreeCursor(
                root: AbsolutePath("/virtual"),
                traversal: .recursive,
                descendingInto: { _ in true },
                metadata: { _ in
                    withUnsafeCurrentTask { XCTAssertNil($0, "Blocking backend must run outside a Swift task") }
                    reads.increment()
                    started.fulfill()
                    _ = releaseRead.wait(timeout: .now() + 5)
                    return FilePropertiesSnapshot(kind: .directory, modificationDate: .distantPast, size: 0)
                },
                children: { _, checkCancellation in
                    try checkCancellation()
                    return ["unread"]
                }
            )
        }
        let consumer = Task {
            var iterator = sequence.makeAsyncIterator()
            return try await iterator.next()
        }
        await fulfillment(of: [started], timeout: 5)
        consumer.cancel()
        releaseRead.signal()
        do {
            _ = try await consumer.value
            XCTFail("Expected cancellation")
        } catch is CancellationError {} catch { XCTFail("Unexpected error: \(error)") }
        XCTAssertEqual(reads.value, 1)
    }

    func test_crossesBatchBoundariesWithoutDroppingOrRepeatingEntries() async throws {
        let root = try temporaryRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        for index in 0..<600 {
            try Data().write(to: root.appendingPathComponent(String(index)))
        }
        var names: [String] = []
        for try await entry in FileSystemEntrySequence.local(at: AbsolutePath(root.path), traversal: .recursive, descendingInto: { _ in true }) {
            names.append(entry.path.lastComponent)
        }
        XCTAssertEqual(names.count, 601)
        XCTAssertEqual(Set(names), Set((0..<600).map(String.init) + [root.lastPathComponent]))
    }

    func test_errorAfterFirstBatchFinishesIterator() async throws {
        let sequence = FileSystemEntrySequence {
            FileTreeCursor(
                root: AbsolutePath("/virtual"),
                traversal: .recursive,
                descendingInto: { _ in true },
                metadata: { path in
                    if path == "/virtual/500" { throw CocoaError(.fileReadNoSuchFile) }
                    return FilePropertiesSnapshot(kind: path == "/virtual" ? .directory : .regularFile, modificationDate: .distantPast, size: 0)
                },
                children: { _, _ in (0..<1000).map(String.init) }
            )
        }
        var iterator = sequence.makeAsyncIterator()
        var delivered = 0
        do {
            while try await iterator.next() != nil { delivered += 1 }
            XCTFail("Expected missing file error")
        } catch {
            XCTAssertEqual((error as? CocoaError)?.code, .fileReadNoSuchFile)
        }
        XCTAssertGreaterThan(delivered, 0)
        let afterError = try await iterator.next()
        XCTAssertNil(afterError)
    }

    private func temporaryRoot() throws -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        return root
    }
}

private final class ReadCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0
    var value: Int {
        lock.lock()
        defer { lock.unlock() }
        return count
    }
    func increment() {
        lock.lock()
        count += 1
        lock.unlock()
    }
}
