import Foundation

public enum FirstNonThrowingResultOf {
    private final class NoWorkWasDoneError: Error, CustomStringConvertible {
        var description: String {
            return "Throwable.works expects array with at least one value"
        }
    }
    
    public static func perform<T>(_ works: () throws -> T...) throws -> T {
        var lastCaughtError: Error?
        for work in works {
            do {
                return try work()
            } catch {
                lastCaughtError = error
            }
        }
        throw (lastCaughtError ?? NoWorkWasDoneError())
    }
}
