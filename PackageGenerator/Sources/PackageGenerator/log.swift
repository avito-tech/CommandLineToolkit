import Foundation

public func log(_ text: String) {
    if ProcessInfo.processInfo.environment["DEBUG"] != nil, let data = (text + "\n").data(using: .utf8) {
        FileHandle.standardOutput.write(data)
    }
}
