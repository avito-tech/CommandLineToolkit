#if os(macOS)
import Darwin
#else
import Glibc
#endif

/// A wrapper to facilitate `print`-ing to stderr and stdio that
/// ensures access to the underlying `FILE` is locked to prevent
/// cross-thread interleaving of output.
struct StdioOutputStream: TextOutputStream {
    let file: UnsafeMutablePointer<FILE>
    let flushMode: FlushMode

    func write(_ string: String) {
        string.withCString { ptr in
            flockfile(self.file)
            defer {
                funlockfile(self.file)
            }
            _ = fputs(ptr, self.file)
            if case .always = self.flushMode {
                self.flush()
            }
        }
    }

    /// Flush the underlying stream.
    /// This has no effect when using the `.always` flush mode, which is the default
    func flush() {
        _ = fflush(self.file)
    }

#if os(macOS)
    static let stderr = StdioOutputStream(file: Darwin.stderr, flushMode: .always)
    static let stdout = StdioOutputStream(file: Darwin.stdout, flushMode: .always)
#else
    static let stderr = StdioOutputStream(file: Glibc.stderr, flushMode: .always)
    static let stdout = StdioOutputStream(file: Glibc.stdout, flushMode: .always)
#endif

    /// Defines the flushing strategy for the underlying stream.
    enum FlushMode {
        case undefined
        case always
    }
}
