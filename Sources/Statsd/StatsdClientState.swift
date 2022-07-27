import Foundation

public enum StatsdClientState: Hashable {
    case notReady
    case ready
    case failed
}
