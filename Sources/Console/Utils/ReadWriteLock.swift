// Grabbed implementation from swift-log
// swiftlint:disable all
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("unsupported runtime")
#endif

/// A reader/writer threading lock based on `libpthread` instead of `libdispatch`.
///
/// This object provides a lock on top of a single `pthread_rwlock_t`. This kind
/// of lock is safe to use with `libpthread`-based threading models, such as the
/// one used by NIO. On Windows, the lock is based on the substantially similar
/// `SRWLOCK` type.
internal final class ReadWriteLock {
    fileprivate let rwlock: UnsafeMutablePointer<pthread_rwlock_t> =
        UnsafeMutablePointer.allocate(capacity: 1)

    /// Create a new lock.
    public init() {
        let err = pthread_rwlock_init(self.rwlock, nil)
        precondition(err == 0, "\(#function) failed in pthread_rwlock with error \(err)")
    }

    deinit {
        let err = pthread_rwlock_destroy(self.rwlock)
        precondition(err == 0, "\(#function) failed in pthread_rwlock with error \(err)")
        self.rwlock.deallocate()
    }

    /// Acquire a reader lock.
    ///
    /// Whenever possible, consider using `withReaderLock` instead of this
    /// method and `unlock`, to simplify lock handling.
    public func lockRead() {
        let err = pthread_rwlock_rdlock(self.rwlock)
        precondition(err == 0, "\(#function) failed in pthread_rwlock with error \(err)")
    }

    /// Acquire a writer lock.
    ///
    /// Whenever possible, consider using `withWriterLock` instead of this
    /// method and `unlock`, to simplify lock handling.
    public func lockWrite() {
        let err = pthread_rwlock_wrlock(self.rwlock)
        precondition(err == 0, "\(#function) failed in pthread_rwlock with error \(err)")
    }

    /// Release the lock.
    ///
    /// Whenever possible, consider using `withReaderLock` and `withWriterLock`
    /// instead of this method and `lockRead` and `lockWrite`, to simplify lock
    /// handling.
    public func unlock() {
        let err = pthread_rwlock_unlock(self.rwlock)
        precondition(err == 0, "\(#function) failed in pthread_rwlock with error \(err)")
    }
}

extension ReadWriteLock {
    /// Acquire the reader lock for the duration of the given block.
    ///
    /// This convenience method should be preferred to `lockRead` and `unlock`
    /// in most situations, as it ensures that the lock will be released
    /// regardless of how `body` exits.
    ///
    /// - Parameter body: The block to execute while holding the reader lock.
    /// - Returns: The value returned by the block.
    @inlinable
    internal func withReaderLock<T>(_ body: () throws -> T) rethrows -> T {
        self.lockRead()
        defer {
            self.unlock()
        }
        return try body()
    }

    /// Acquire the writer lock for the duration of the given block.
    ///
    /// This convenience method should be preferred to `lockWrite` and `unlock`
    /// in most situations, as it ensures that the lock will be released
    /// regardless of how `body` exits.
    ///
    /// - Parameter body: The block to execute while holding the writer lock.
    /// - Returns: The value returned by the block.
    @inlinable
    internal func withWriterLock<T>(_ body: () throws -> T) rethrows -> T {
        self.lockWrite()
        defer {
            self.unlock()
        }
        return try body()
    }

    // specialise Void return (for performance)
    @inlinable
    internal func withReaderLockVoid(_ body: () throws -> Void) rethrows {
        try self.withReaderLock(body)
    }

    // specialise Void return (for performance)
    @inlinable
    internal func withWriterLockVoid(_ body: () throws -> Void) rethrows {
        try self.withWriterLock(body)
    }
}
