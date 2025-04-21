import AtomicModels
import Dispatch
import Foundation

public final class BlockingArrayBasedJSONStream: AppendableJSONStream {
    private let lock = NSLock()
    private let writeLock = DispatchSemaphore(value: 0)
    
    private var storage = [UInt8]()
    
    private var willProvideMoreData = true
    
    public init() {}
    
    public func append(bytes: [UInt8]) {
        lock.lock()
        defer { lock.unlock() }

        storage.insert(contentsOf: bytes.reversed(), at: 0)
        onNewData()
    }
    
    // MARK: - JSONStream
    
    public func touch() -> UInt8? {
        return lastByte(delete: false)
    }
    
    public func read() -> UInt8? {
        return lastByte(delete: true)
    }
    
    public func close() {
        lock.lock()
        defer { lock.unlock() }

        willProvideMoreData = false
        onStreamClose()
    }
    
    private func lastByte(delete: Bool) -> UInt8? {
        lock.lock()
        if storage.isEmpty {
            if willProvideMoreData {
                lock.unlock()
                // It stil may suffer from data races in the edge case of closing this stream
                // TODO: use conditiona variable
                waitForNewDataOrStreamCloseEvent()
                lock.lock()
            } else {
                lock.unlock()
                return nil
            }
        }
        
        defer { lock.unlock() }
        if delete {
            return storage.popLast()
        } else {
            return storage.last
        }
    }
    
    private func waitForNewDataOrStreamCloseEvent() {
        writeLock.waitForUnblocking()
    }
    
    private func onNewData() {
        writeLock.unblock()
    }
    
    private func onStreamClose() {
        writeLock.unblock()
    }
}

extension DispatchSemaphore {
    func waitForUnblocking() {
        wait()
        signal()
    }
    
    func unblock() {
        signal()
        wait()
    }
}
