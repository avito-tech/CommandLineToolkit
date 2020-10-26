import Foundation

public enum Throwable {
    public static func perform<T>(_ works: () throws -> T...) throws -> T {
        var caughtError: Error?
        for work in works {
            do {
                return try work()
            } catch {
                caughtError = error
            }
        }
        if let caughtError = caughtError {
            throw caughtError
        } else {
            fatalError("Throwable.perform() did not caught any error, this should not happen")
        }
    }
}
