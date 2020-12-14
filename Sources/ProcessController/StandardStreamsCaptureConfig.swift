import Foundation
import PathLib

public final class StandardStreamsCaptureConfig: CustomStringConvertible {
    public let stdoutPath: AbsolutePath?
    public let stderrPath: AbsolutePath?

    public init(
        stdoutPath: AbsolutePath? = nil,
        stderrPath: AbsolutePath? = nil
    ) {
        self.stdoutPath = stdoutPath
        self.stderrPath = stderrPath
    }
    
    public var description: String {
        let stdout = stdoutPath?.pathString ?? "null"
        let stderr = stderrPath?.pathString ?? "null"
        return "<stdout: \(stdout), stderr: \(stderr)>"
    }
}

extension StandardStreamsCaptureConfig {
    func byRedefiningIfNotSet(
        stdoutOutputPath: AbsolutePath,
        stderrOutputPath: AbsolutePath
    ) -> StandardStreamsCaptureConfig {
        StandardStreamsCaptureConfig(
            stdoutPath: stdoutPath ?? stdoutOutputPath,
            stderrPath: stderrPath ?? stderrOutputPath
        )
    }
}
