import Foundation
import PathLib

public final class ThrowingThreadSafeLazy<T> {
    private let threadSafeLazy: ThreadSafeLazy<Result<T, Error>>
    
    public init(factory: @escaping () throws -> T) {
        self.threadSafeLazy = ThreadSafeLazy {
            do {
                return .success(try factory())
            } catch {
                return .failure(error)
            }
        }
    }
    
    public var value: T {
        get throws {
            let value = try threadSafeLazy.value
            
            switch value {
            case .success(let success):
                return success
            case .failure(let error):
                throw error
            }
        }
    }
}
