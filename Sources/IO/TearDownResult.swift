import Foundation

public enum TearDownResult: Hashable {
    case successfullyFlushedInTime
    case flushTimeout
}
