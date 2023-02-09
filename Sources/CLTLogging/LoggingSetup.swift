/*
 * Copyright (c) Avito Tech LLC
 */

import DateProvider
import Dispatch
import FileSystem
import CLTLoggingModels
import Foundation
import Kibana
import KibanaModels
import PathLib
import Tmp

public final class LoggingSetup {
    private let dateProvider: DateProvider
    private let fileSystem: FileSystem
    private let logDomainName: String
    private let logFileExtension = "log"
    private let logFilePrefix = "pid_"
    private let logFilesCleanUpRegularity: TimeInterval = 10800
    private let aggregatedLoggerHandler: AggregatedLoggerHandler
    private let pluggableLoggerHandlerForKibana = RedirectingLoggerHandler()
    public let rootLoggerHandler: LoggerHandler
    
    public init(
        dateProvider: DateProvider,
        fileSystem: FileSystem,
        logDomainName: String
    ) {
        self.dateProvider = dateProvider
        self.fileSystem = fileSystem
        self.logDomainName = logDomainName
        self.aggregatedLoggerHandler = AggregatedLoggerHandler(handlers: [])
        self.rootLoggerHandler = self.aggregatedLoggerHandler
    }
    
    public func createLogger(
        stderrVerbosity: Verbosity,
        detailedLogVerbosity: Verbosity?,
        kibanaVerbosity: Verbosity
    ) throws -> ContextualLogger {
        let logger = ContextualLogger(
            dateProvider: dateProvider,
            loggerHandler: rootLoggerHandler,
            metadata: [:]
        )
        add(
            loggerHandler: createStderrInfoLoggerHandler(
                verbosity: stderrVerbosity
            )
        )
        add(
            loggerHandler: LimitingLoggerHandler(
                maximumVerbosity: kibanaVerbosity,
                target: pluggableLoggerHandlerForKibana
            )
        )
        if let detailedLogVerbosity = detailedLogVerbosity {
            let filename = logFilePrefix + String(ProcessInfo.processInfo.processIdentifier)
            let detailedLogPath = try TemporaryFile(
                containerPath: try logsContainerFolder(),
                prefix: filename,
                suffix: "." + logFileExtension,
                deleteOnDealloc: false
            )
            add(
                loggerHandler: createDetailedLoggerHandler(
                    fileHandle: detailedLogPath.fileHandleForWriting,
                    verbosity: detailedLogVerbosity
                )
            )
            logger.info("Verbose logs available at: \(detailedLogPath.absolutePath)")
        }
        
        return logger
    }
    
    public func set(
        kibanaConfiguration: KibanaConfiguration
    ) throws {
        let handler = KibanaLoggerHandler(
            kibanaClient: try HttpKibanaClient(
                dateProvider: dateProvider,
                endpoints: try kibanaConfiguration.endpoints.map { try KibanaHttpEndpoint.from(url: $0) },
                indexPattern: kibanaConfiguration.indexPattern,
                urlSession: .shared
            )
        )
        pluggableLoggerHandlerForKibana.setTarget(handler)
    }
    
    public func childProcessLogsContainerProvider() throws -> ChildProcessLogsContainerProvider {
        return ChildProcessLogsContainerProviderImpl(
            fileSystem: fileSystem,
            mainContainerPath: try logsContainerFolder()
        )
    }
    
    public func add(loggerHandler: LoggerHandler) {
        aggregatedLoggerHandler.append(handler: loggerHandler)
    }
    
    public func tearDown(timeout: TimeInterval) {
        aggregatedLoggerHandler.tearDownLogging(timeout: timeout)
    }
    
    public func cleanUpLogs(
        logger: ContextualLogger,
        logDomainName: String,
        olderThan date: Date,
        queue: OperationQueue,
        completion: @escaping (Error?) -> ()
    ) throws {
        let logsCleanUpMarkerFileProperties = fileSystem.properties(
            path: try fileSystem.logsCleanUpMarkerFile(
                logDomainName: logDomainName
            )
        )
        guard dateProvider.currentDate().timeIntervalSince(
            try logsCleanUpMarkerFileProperties.modificationDate.get()
        ) > logFilesCleanUpRegularity else {
            logger.trace("Skipping log clean up since last clean up happened recently")
            return
        }
        
        logger.trace("Cleaning up old log files")
        try logsCleanUpMarkerFileProperties.touch()
        
        let logsEnumerator = fileSystem.contentEnumerator(
            forPath: try fileSystem.logsFolder(
                logDomainName: logDomainName
            ),
            style: .deep
        )

        queue.addOperation {
            do {
                try logsEnumerator.each { (path: AbsolutePath) in
                    guard path.extension == self.logFileExtension else { return }
                    let modificationDate = try self.fileSystem.properties(path: path).modificationDate.get()
                    if modificationDate < date {
                        do {
                            try self.fileSystem.delete(path: path)
                        } catch {
                            logger.error("Failed to remove old log file at \(path): \(error)")
                        }
                    }
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    private func createStderrInfoLoggerHandler(
        verbosity: Verbosity
    ) -> LoggerHandler {
        return LimitingLoggerHandler(
            maximumVerbosity: verbosity,
            target: FileHandleLoggerHandler(
                dateProvider: dateProvider,
                fileHandle: FileHandle.standardError,
                logEntryTextFormatter: NSLogLikeLogEntryTextFormatter(
                    logLocation: false,
                    logCoordinates: false
                ),
                fileHandleShouldBeClosed: false,
                skipMetadataFlag: .skipStdOutput
            )
        )
    }
    
    private func createDetailedLoggerHandler(
        fileHandle: FileHandle,
        verbosity: Verbosity
    ) -> LoggerHandler {
        return LimitingLoggerHandler(
            maximumVerbosity: verbosity,
            target: FileHandleLoggerHandler(
                dateProvider: dateProvider,
                fileHandle: fileHandle,
                logEntryTextFormatter: NSLogLikeLogEntryTextFormatter(
                    logLocation: true,
                    logCoordinates: true
                ),
                fileHandleShouldBeClosed: true,
                skipMetadataFlag: .skipFileOutput
            )
        )
    }
    
    private func logsContainerFolder() throws -> AbsolutePath {
        try fileSystem.folderForStoringLogs(
            logDomainName: logDomainName,
            processName: ProcessInfo.processInfo.processName
        )
    }
}
