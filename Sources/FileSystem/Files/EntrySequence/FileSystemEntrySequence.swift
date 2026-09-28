import Foundation
import PathLib

public struct FileSystemEntry: Sendable {
    public let path: AbsolutePath
    public let metadata: FilePropertiesSnapshot

    public init(path: AbsolutePath, metadata: FilePropertiesSnapshot) {
        self.path = path
        self.metadata = metadata
    }
}

public enum FileSystemTraversal: Sendable {
    case shallow
    case recursive
}

/// A lazy walk including the entry at `root`, followed by its descendants.
/// A shallow walk includes the root and its immediate children. Links are
/// returned as entries and never followed. The order is unspecified.
///
/// Each new iterator owns an independent cursor. Copies share that cursor;
/// advance an iterator and its copies sequentially, never concurrently.
/// Blocking reads run on a bounded queue, in demand-driven batches. Stopping
/// iteration schedules no further work; no descriptors survive a batch.
public struct FileSystemEntrySequence: AsyncSequence {
    public typealias Element = FileSystemEntry
    private let makeCursor: () -> FileTreeCursor

    init(makeCursor: @escaping () -> FileTreeCursor) {
        self.makeCursor = makeCursor
    }

    public func makeAsyncIterator() -> Iterator {
        Iterator(cursor: makeCursor())
    }

    public struct Iterator: AsyncIteratorProtocol {
        private let state: CursorState
        private var buffer: [FileSystemEntry] = []
        private var index = 0
        private var reachedEnd = false

        fileprivate init(cursor: FileTreeCursor) {
            state = CursorState(cursor: cursor)
        }

        public mutating func next() async throws -> FileSystemEntry? {
            try Task.checkCancellation()
            if index == buffer.count {
                guard !reachedEnd else { return nil }
                let state = state
                do {
                    let batch = try await withTaskCancellationHandler {
                        try await withCheckedThrowingContinuation { continuation in
                            FileSystemReadQueue.shared.addOperation {
                                continuation.resume(with: Result { try state.nextBatch() })
                            }
                        }
                    } onCancel: {
                        state.cancel()
                    }
                    buffer = batch.entries
                    reachedEnd = batch.isLast
                    index = 0
                } catch {
                    reachedEnd = true
                    buffer = []
                    index = 0
                    throw error
                }
                try Task.checkCancellation()
                if buffer.isEmpty {
                    reachedEnd = true
                    return nil
                }
            }
            defer { index += 1 }
            return buffer[index]
        }
    }
}

private enum FileSystemReadQueue {
    static let shared: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "CommandLineToolkit.FileSystem.entries"
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = max(1, ProcessInfo.processInfo.activeProcessorCount)
        return queue
    }()
}

/// Only the cancellation flag is accessed concurrently. Cursor access is
/// confined to the queue and successive next() calls never overlap.
private final class CursorState: @unchecked Sendable {
    private var cursor: FileTreeCursor
    private let lock = NSLock()
    private var cancelled = false

    init(cursor: FileTreeCursor) { self.cursor = cursor }

    func cancel() {
        lock.lock()
        cancelled = true
        lock.unlock()
    }

    private func checkCancellation() throws {
        lock.lock()
        let cancelled = cancelled
        lock.unlock()
        if cancelled { throw CancellationError() }
    }

    func nextBatch() throws -> (entries: [FileSystemEntry], isLast: Bool) {
        var result: [FileSystemEntry] = []
        result.reserveCapacity(256)
        try checkCancellation()
        for _ in 0..<256 {
            guard let entry = try cursor.next(checkCancellation: checkCancellation) else { break }
            result.append(entry)
        }
        return (result, cursor.isFinished)
    }
}

/// An explicit stack holds unvisited siblings rather than open directories.
/// The backend is synchronous so virtual filesystems can share traversal rules.
struct FileTreeCursor {
    private var pending: [(path: String, depth: Int)]
    private let traversal: FileSystemTraversal
    private let descendingInto: @Sendable (FileSystemEntry) -> Bool
    private let metadata: (String) throws -> FilePropertiesSnapshot
    private let children: (String, () throws -> Void) throws -> [String]

    init(
        root: AbsolutePath,
        traversal: FileSystemTraversal,
        descendingInto: @escaping @Sendable (FileSystemEntry) -> Bool,
        metadata: @escaping (String) throws -> FilePropertiesSnapshot,
        children: @escaping (String, () throws -> Void) throws -> [String]
    ) {
        pending = [(root.pathString, 0)]
        self.traversal = traversal
        self.descendingInto = descendingInto
        self.metadata = metadata
        self.children = children
    }

    var isFinished: Bool { pending.isEmpty }

    mutating func next(checkCancellation: () throws -> Void) throws -> FileSystemEntry? {
        guard let item = pending.popLast() else { return nil }
        try checkCancellation()
        let entry = try FileSystemEntry(path: AbsolutePath(item.path), metadata: metadata(item.path))
        if entry.metadata.kind == .directory,
           traversal == .recursive || item.depth == 0, descendingInto(entry) {
            let prefix = item.path.hasSuffix("/") ? item.path : item.path + "/"
            let names = try children(item.path, checkCancellation)
            pending.append(contentsOf: names.reversed().map { (prefix + $0, item.depth + 1) })
        }
        return entry
    }
}

extension FileSystemEntrySequence {
    static func local(
        at root: AbsolutePath,
        traversal: FileSystemTraversal,
        descendingInto: @escaping @Sendable (FileSystemEntry) -> Bool
    ) -> Self {
        Self {
            FileTreeCursor(
                root: root,
                traversal: traversal,
                descendingInto: descendingInto,
                metadata: { try FilePropertiesSnapshot.read(path: $0, followSymbolicLinks: false) },
                children: DirectoryEntries.names
            )
        }
    }
}
