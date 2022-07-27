import Foundation

public protocol EasyOutputStream {
    func open() throws
    func close()
    
    func waitAndClose(timeout: TimeInterval) -> TearDownResult
    func enqueueWrite(data: Data) throws
}
