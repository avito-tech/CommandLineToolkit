import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// A directory is always closed before returning, including errors/cancellation.
enum DirectoryEntries {
    static func names(at path: String, checkCancellation: () throws -> Void) throws -> [String] {
        try checkCancellation()
        guard let directory = opendir(path) else { throw fileSystemError(operation: "opendir", path: path) }
        defer { closedir(directory) }
        var names: [String] = []
        while true {
            try checkCancellation()
            errno = 0
            guard let entry = readdir(directory) else {
                guard errno == 0 else { throw fileSystemError(operation: "readdir", path: path) }
                return names
            }
            let name = withUnsafePointer(to: &entry.pointee.d_name) { pointer in
                pointer.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: entry.pointee.d_name)) {
                    String(cString: $0)
                }
            }
            if name != ".", name != ".." { names.append(name) }
        }
    }
}

func fileSystemError(operation: String, path: String) -> NSError {
    let code = errno
    return NSError(domain: NSPOSIXErrorDomain, code: Int(code), userInfo: [
        NSFilePathErrorKey: path,
        NSLocalizedDescriptionKey: "\(operation) failed at \(path): \(String(cString: strerror(code)))",
    ])
}
