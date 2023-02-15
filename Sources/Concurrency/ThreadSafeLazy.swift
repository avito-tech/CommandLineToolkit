import Foundation
import PathLib

public final class ThreadSafeLazy<T> {
    private let lock = NSLock()
    private let factory: () -> T
    
    private var cachedValue: T?
    
    public init(factory: @escaping () -> T) {
        self.factory = factory
    }
    
    public var value: T {
        get throws {
            if let cachedValue = cachedValue {
                return cachedValue
            } else {
                lock.lock()
                
                defer {
                    lock.unlock()
                }
                
                if let cachedValue = cachedValue {
                    return cachedValue
                } else {
                    let cachedValue = factory()
                    self.cachedValue = cachedValue
                    return cachedValue
                }
            }
        }
    }
}
