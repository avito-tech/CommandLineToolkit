/*
 * Copyright (c) Avito Tech LLC
 */

import Foundation
import FileSystem
import PathLib

public extension FileSystem {
    func logsFolder(
        logDomainName: String
    ) throws -> AbsolutePath {
        let libraryPath = try commonlyUsedPathsProvider.library(inDomain: .user, create: false)
        return libraryPath.appending("Logs", logDomainName)
    }
    
    func logsCleanUpMarkerFile(
        logDomainName: String
    ) throws -> AbsolutePath {
        let path = try logsFolder(
            logDomainName: logDomainName
        ).appending("logs_cleanup_marker")
        if !properties(path: path).exists() {
            try createFile(path: path, data: nil)
        }
        return path
    }
    
    func folderForStoringLogs(
        logDomainName: String,
        processName: String
    ) throws -> AbsolutePath {
        let container = try logsFolder(logDomainName: logDomainName).appending(processName)
        try createDirectory(path: container, withIntermediateDirectories: true)
        return container
    }
}
