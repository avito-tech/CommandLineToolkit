import PlistLib
import UserDefaultsLib

open class FakeDefaults: Defaults {
    public var storage = [String: PlistEntry]()
    
    public init() {}
    
    public func entryForKey(_ key: String) throws -> PlistEntry? {
        storage[key]
    }
    
    public func set(entry: PlistEntry?, key: String) {
        storage[key] = entry
    }
    
    public func removeEntryForKey(_ key: String) {
        storage.removeValue(forKey: key)
    }
}
