/*
 * Copyright (c) Avito Tech LLC
 */

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class FakeURLSession: URLSession, @unchecked Sendable {
    let session = URLSession.shared
    
    public var providedDownloadTasks = [FakeDownloadTask]()

#if os(Linux)
    public convenience init() {
        self.init(configuration: .default)
    }
#endif
    
    override public func downloadTask(with request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> ()) -> URLSessionDownloadTask {
        let task = FakeDownloadTask(
            originalTask: session.downloadTask(with: request, completionHandler: completionHandler),
            completionHandler: completionHandler
        )
        providedDownloadTasks.append(task)
        return task
    }
    
    public var providedDataTasks = [FakeDataTask]()

    override public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) -> URLSessionDataTask {
        let task = FakeDataTask(
            originalTask: session.dataTask(with: request, completionHandler: completionHandler),
            completionHandler: completionHandler
        )
        providedDataTasks.append(task)
        return task
    }
}

public class FakeDownloadTask: URLSessionDownloadTask, @unchecked Sendable {
    public var originalTask: URLSessionTask
    public var completionHandler: (URL?, URLResponse?, Error?) -> ()
    
    public init(originalTask: URLSessionTask, completionHandler: @escaping (URL?, URLResponse?, Error?) -> ()) {
        self.originalTask = originalTask
        self.completionHandler = completionHandler
    }
    
#if os(macOS)
    @objc private func _onqueue_resume() {
        originalTask.perform(#selector(self._onqueue_resume))
    }
#endif
}

public class FakeDataTask: URLSessionDataTask, @unchecked Sendable {
    public var originalTask: URLSessionTask
    public var completionHandler: (Data?, URLResponse?, Error?) -> ()
    
    public init(originalTask: URLSessionTask, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        self.originalTask = originalTask
        self.completionHandler = completionHandler
    }
    
#if os(macOS)
    @objc private func _onqueue_resume() {
        originalTask.perform(#selector(self._onqueue_resume))
    }
#endif
}
