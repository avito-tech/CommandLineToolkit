import DateProvider
import Foundation
import FileSystem
import PathLib

public final class DefaultProcessControllerProvider: ProcessControllerProvider {
    private let dateProvider: DateProvider
    private let filePropertiesProvider: FilePropertiesProvider
    
    public init(
        dateProvider: DateProvider,
        filePropertiesProvider: FilePropertiesProvider
    ) {
        self.dateProvider = dateProvider
        self.filePropertiesProvider = filePropertiesProvider
    }
    
    public func createProcessController(subprocess: Subprocess) throws -> ProcessController {
        return try DefaultProcessController(
            dateProvider: dateProvider,
            filePropertiesProvider: filePropertiesProvider,
            subprocess: subprocess
        )
    }
}
