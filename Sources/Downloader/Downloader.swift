import Foundation
import PathLib

public struct DownloadProgress {
    public let bytesCompleted: Int64
    public let bytesTotal: Int64
    public let bytesPerSecond: Double
    
    public var fraction: Double {
        Double(bytesCompleted) / Double(bytesTotal)
    }
}

public protocol Downloader {
    func download(
        url: URL,
        callbackQueue: DispatchQueue,
        progressHandler: @escaping (DownloadProgress) -> (),
        completion: @escaping (Result<AbsolutePath, Error>) -> ()
    )
    
    func download(
        url: URL,
        progressHandler: @escaping (DownloadProgress) -> ()
    ) async -> Result<AbsolutePath, Error>
}

public extension Downloader {
    func download(url: URL) async -> Result<AbsolutePath, Error> {
        return await download(url: url, progressHandler: { _ in })
    }

}
