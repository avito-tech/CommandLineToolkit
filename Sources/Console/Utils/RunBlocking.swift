import Foundation

private final class RunBlocking<T, Failure: Error> {
    fileprivate var value: Result<T, Failure>?
}

extension RunBlocking where Failure == Never {
    func runBlocking(_ operation: @Sendable @escaping () async -> T) -> T {
        Task {
            let task = Task(operation: operation)
            self.value = await task.result
        }
        DispatchQueue.global().sync {
            while value == nil {
                RunLoop.current.run(mode: .default, before: .distantFuture)
            }
        }
        switch value {
        case let .success(value):
            return value
        case .none:
            fatalError("Run blocking not received value")
        }
    }
}

extension RunBlocking where Failure == Error {
    func runBlocking(_ operation: @Sendable @escaping () async throws -> T) throws -> T {
        Task {
            let task = Task(operation: operation)
            value = await task.result
        }
        DispatchQueue.global().sync {
            while value == nil {
                RunLoop.current.run(mode: .default, before: .distantFuture)
            }
        }
        switch value {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        case .none:
            fatalError("Run blocking not received value")
        }
    }
}

func runBlocking<T>(
    @_implicitSelfCapture _ operation: @Sendable @escaping () async -> T
) -> T {
    RunBlocking().runBlocking(operation)
}

func runBlocking<T>(
    @_implicitSelfCapture _ operation: @Sendable @escaping () async throws -> T
) throws -> T {
    try RunBlocking().runBlocking(operation)
}
