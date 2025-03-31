/*
 * Copyright (c) Avito Tech LLC
 */

import Foundation
import FileSystem
import PathLib
import Tmp

public protocol ChildProcessLogsContainerProvider {
    func files(subprocessName: String) throws -> (stdout: TemporaryFile, stderr: TemporaryFile)
}

public final class ChildProcessLogsContainerProviderImpl: ChildProcessLogsContainerProvider {
    private let fileSystem: FileSystem
    private let mainContainerPath: AbsolutePath
    
    public init(
        fileSystem: FileSystem,
        mainContainerPath: AbsolutePath
    ) {
        self.fileSystem = fileSystem
        self.mainContainerPath = mainContainerPath
    }
    
    public func files(subprocessName: String) throws -> (stdout: TemporaryFile, stderr: TemporaryFile) {
        let subprocessSpecificContainer = mainContainerPath.appending(
            components: ["subprocesses", subprocessName]
        )
        try fileSystem.createDirectory(path: subprocessSpecificContainer, withIntermediateDirectories: true)

        func createLogTemporaryFile(name: String) throws -> TemporaryFile {
            try TemporaryFile(
                containerPath: subprocessSpecificContainer,
                prefix: subprocessName,
                suffix: ".\(name).log",
                deleteOnDealloc: false
            )
        }
        
        return try (
            stdout: createLogTemporaryFile(name: "stdout"),
            stderr: createLogTemporaryFile(name: "stderr")
        )
    }
}
