import Foundation

public struct SubprocessInfo: Equatable {
    public let subprocessId: Int32
    public let subprocessName: String

    public init(subprocessId: Int32, subprocessName: String) {
        self.subprocessId = subprocessId
        self.subprocessName = subprocessName
    }
}
