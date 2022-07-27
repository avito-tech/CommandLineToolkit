import Foundation

public final class LinuxEasyOutputStream: EasyOutputStream {
    public init() {}
    
    public struct LinuxIsNotSupported: Error, CustomStringConvertible {
        public var description: String {
            "Linux does not yet support EasyOutputStream"
        }
    }
    
    public func open() throws {
        throw LinuxIsNotSupported()
    }
    
    public func close() {
        
    }
    
    public func enqueueWrite(data: Data) throws {
        throw LinuxIsNotSupported()
    }
    
    public func waitAndClose(timeout: TimeInterval) -> TearDownResult {
        return .successfullyFlushedInTime
    }
}
