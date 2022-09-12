import Foundation
import Types

extension Collection where Self.Index == Int {
    public func throwingConcurrentMap<T, R>(
        mapping: (T) throws -> (R)
    ) throws -> [R] where T == Element {
        return try returnOutput(
            results: concurrentMap { arg -> Either<R, Error> in
                do {
                    return try Either.success(mapping(arg))
                } catch {
                    return Either.error(error)
                }
            }
        )
    }
    
    public func throwingConcurrentReduce<T, K, R>(
        _ initialValue: R,
        mapping: (T) throws -> (K),
        reduction: (inout R, K) throws -> ()
    ) throws -> R where T == Element {
        let result = concurrentReduce(
            ([Error](), initialValue),
            mapping: { arg -> Either<K, Error> in
                do {
                    return try Either.success(mapping(arg))
                } catch {
                    return Either.error(error)
                }
            },
            reduction: { errorsAndAccumulator, arg in
                switch arg {
                case let .left(output):
                    do {
                        try reduction(&errorsAndAccumulator.1, output)
                    } catch {
                        errorsAndAccumulator.0.append(error)
                    }
                case let .right(error):
                    errorsAndAccumulator.0.append(error)
                }
            }
        )
        let errors = result.0
        guard errors.isEmpty else {
            throw CompoundError(errors: errors)
        }
        return result.1
    }
    
    public func throwingConcurrentForEach<T>(
        perform: (T) throws -> ()
    ) throws where T == Element {
        _ = try throwingConcurrentMap(mapping: { try perform($0) })
    }
    
    public func concurrentMap<T, R>(
        mapping: (T) -> (R)
    ) -> [R] where T == Element {
        var mappingResult = [R?](repeating: nil, count: count)
        let lock = NSLock()
        DispatchQueue.concurrentPerform(
            iterations: count,
            execute: { index in
                let iterationResult = mapping(self[index])
                lock.lock()
                mappingResult[index] = iterationResult
                lock.unlock()
            }
        )
        return mappingResult.compactMap { $0 }
    }
    
    public func concurrentCompactMap<T, R>(
        mapping: (T) -> (R?)
    ) -> [R] where T == Element {
        var mappingResult = [R?](repeating: nil, count: count)
        let lock = NSLock()
        DispatchQueue.concurrentPerform(
            iterations: count,
            execute: { index in
                let optionalIterationResult = mapping(self[index])
                lock.lock()
                if let iterationResult = optionalIterationResult {
                    mappingResult[index] = iterationResult
                }
                lock.unlock()
            }
        )
        return mappingResult.compactMap { $0 }
    }

    public func concurrentReduce<T, K, R>(
        _ initialValue: R,
        mapping: (T) -> (K),
        reduction: (inout R, K) -> ()
    ) -> R where T == Element {
        var result = initialValue
        let lock = NSLock()
        DispatchQueue.concurrentPerform(
            iterations: count,
            execute: { index in
                let iterationResult = mapping(self[index])
                lock.lock()
                reduction(&result, iterationResult)
                lock.unlock()
            }
        )
        return result
    }
    
    public func concurrentForEach<T>(
        perform: (T) -> ()
    ) where T == Element {
        DispatchQueue.concurrentPerform(
            iterations: count,
            execute: { index in
                perform(self[index])
            }
        )
    }
    
    private func returnOutput<R>(
        results: [Either<R, Error>]
    ) throws -> [R] {
        let (errors, outputs) = results.reduce(into: ([Error](), [R]())) { errorsAndOutputs, result in
            switch result {
            case let .right(error):
                errorsAndOutputs.0.append(error)
            case let .left(output):
                errorsAndOutputs.1.append(output)
            }
        }
        guard errors.isEmpty else {
            throw CompoundError(errors: errors)
        }
        return outputs
    }
}
