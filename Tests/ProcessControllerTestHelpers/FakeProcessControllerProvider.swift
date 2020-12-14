@testable import ProcessController
import Foundation
import Tmp

public final class FakeProcessControllerProvider: ProcessControllerProvider {
    public var tempFolder: TemporaryFolder
    public var creator: (Subprocess) throws -> (ProcessController)
    
    public init(
        tempFolder: TemporaryFolder,
        creator: @escaping (Subprocess) throws -> ProcessController = { FakeProcessController(subprocess: $0) }
    ) {
        self.tempFolder = tempFolder
        self.creator = creator
    }
    
    public func createProcessController(subprocess: Subprocess) throws -> ProcessController {
        return try creator(subprocess)
    }
}
