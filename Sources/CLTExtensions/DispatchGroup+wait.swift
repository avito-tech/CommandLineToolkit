import Foundation

public extension DispatchGroup {
    @discardableResult
    static func wait<T>(closure: (Continuation<T, Error>) throws -> ()) throws -> WaitResult<T> {
        try wait(timeout: .distantFuture, closure: closure)
    }
    
    @discardableResult
    static func wait<T>(closure: (Continuation<T, Never>) throws -> ()) rethrows -> WaitResult<T> {
        try wait(timeout: .distantFuture, closure: closure)
    }
    
    @discardableResult
    static func wait<T>(timeout: DispatchTime, closure: (Continuation<T, Error>) throws -> ()) throws -> WaitResult<T> {
        let waitGroup = DispatchGroup()
        waitGroup.enter()
        let waitContinuation = Continuation<T, Error>(waitGroup.leave)
        try closure(waitContinuation)
        switch waitGroup.wait(timeout: timeout) {
        case .success:
            return .success(try waitContinuation.getResult())
        case .timedOut:
            return .timedOut
        }
    }

    @discardableResult
    static func wait<T>(timeout: DispatchTime, closure: (Continuation<T, Never>) throws -> ()) rethrows -> WaitResult<T> {
        let waitGroup = DispatchGroup()
        waitGroup.enter()
        let waitContinuation = Continuation<T, Never>(waitGroup.leave)
        try closure(waitContinuation)
        switch waitGroup.wait(timeout: timeout) {
        case .success:
            return .success(waitContinuation.value)
        case .timedOut:
            return .timedOut
        }
    }
    
    enum WaitResult<T> {
        case success(T)
        case timedOut
        
        public func get() throws -> T {
            switch self {
            case .success(let value):
                return value
            case .timedOut:
                throw WaitTimedOutError(errorDescription: "DispatchGroup.wait(timeout:closure:) finished with WaitResult<\(T.self)>.timedOut")
            }
        }
    }
    
    struct WaitTimedOutError: LocalizedError {
        public var errorDescription: String
    }
    
    final class Continuation<Success, Failure> where Failure: Error {
        private let closure: () -> ()
        private var result: Result<Success, Failure>?

        fileprivate init(_ closure: @escaping () -> ()) {
            self.closure = closure
        }

        public func resume(with result: Result<Success, Failure>) {
            guard self.result == nil else { return }
            self.result = result
            closure()
        }

        fileprivate func getResult() throws -> Success {
            guard let result = result else {
                fatalError("\(type(of: self)): resume(with:) was never called")
            }
            return try result.get()
        }
    }
}

extension DispatchGroup.Continuation where Failure == Never {
    public func resume(with value: Success) {
        resume(with: .success(value))
    }
    
    fileprivate var value: Success {
        do {
            return try getResult()
        } catch {
            fatalError("Unexpected error: \(error.localizedDescription)")
        }
    }
}
