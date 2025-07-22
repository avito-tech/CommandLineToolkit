import Foundation
import AtomicModels

public final class TraceMetadata {
    @TaskLocal public static var current: TraceMetadata = .init()

    @AtomicValue
    public private(set) var metadata: [String: TraceMetadataValue] = [:]

    init() {}

    public subscript (_ key: String) -> TraceMetadataValue? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }
}
