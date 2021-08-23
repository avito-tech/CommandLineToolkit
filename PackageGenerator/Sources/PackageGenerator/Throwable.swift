import Foundation

public enum Throwable {
    public static func perform<T>(_ works: () throws -> T...) throws -> T {
        var lastCaughtError: Error!
        for work in works {
            do {
                return try work()
            } catch {
                lastCaughtError = error
            }
        }
        throw lastCaughtError
    }
}
