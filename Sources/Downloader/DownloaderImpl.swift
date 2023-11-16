import Alamofire
import DateProvider
import Foundation
import PathLib

public final class DownloaderImpl: Downloader {
    private struct NoFileURL: Error, CustomStringConvertible {
        let description = "No File URL provided in completion handler"
    }
    
    private let dateProvider: DateProvider
    
    public init(dateProvider: DateProvider) {
        self.dateProvider = dateProvider
    }
    
    public func download(
        url: URL,
        callbackQueue: DispatchQueue,
        progressHandler: @escaping (DownloadProgress) -> (),
        completion: @escaping (Result<AbsolutePath, Error>) -> ()
    ) {
        let downloadStartedAt = dateProvider.currentDate()
        AF.download(
            url,
            method: .get
        ).downloadProgress(
            queue: callbackQueue,
            closure: { [weak self] progress in
                guard let self else { return }
                let downloadProgress = self.calculateProgressFrom(startedAt: downloadStartedAt, progress: progress)
                progressHandler(downloadProgress)
            }
        ).response(
            queue: callbackQueue,
            completionHandler: { response in
                let response = response.tryMap { (fileUrl: URL?) -> AbsolutePath in
                    guard let url = fileUrl else {
                        throw NoFileURL()
                    }
                    return AbsolutePath(url)
                }
                callbackQueue.async {
                    completion(response.result)
                }
            }
        )
    }
    
    public func download(
        url: URL,
        progressHandler: @escaping (DownloadProgress) -> () = { _ in }
    ) async -> Result<AbsolutePath, Error> {
        let downloadStartedAt = dateProvider.currentDate()
        let request = AF.download(url, method: .get)
        request.validate()
        
        Task {
            for await progress in request.downloadProgress() {
                let downloadProgress = calculateProgressFrom(startedAt: downloadStartedAt, progress: progress)
                progressHandler(downloadProgress)
            }
        }

        let response = await request.serializingDownloadedFileURL().response.tryMap({ (fileUrl: URL?) -> AbsolutePath in
            guard let url = fileUrl else {
                throw NoFileURL()
            }
            return AbsolutePath(url)
        })
        
        return response.result
    }
    
    private func calculateProgressFrom(startedAt: Date, progress: Progress) -> DownloadProgress {
        let downloadDuration = dateProvider.currentDate().timeIntervalSince(startedAt)
        return DownloadProgress(
            bytesCompleted: progress.completedUnitCount,
            bytesTotal: progress.totalUnitCount,
            bytesPerSecond: Double(progress.completedUnitCount) / fmax(downloadDuration, 0.1)
        )
    }
}
