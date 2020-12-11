import Foundation
import PlistLib

public final class SystemDefaults: Defaults {
    private let userDefaults: UserDefaults
    
    public struct CannotCreateUserDefaultsError: CustomStringConvertible, Error {
        let suiteName: String
        public var description: String {
            "Не могу создать user defaults для набора \(suiteName)"
        }
    }
    
    public init(
        suiteName: String
    ) throws {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw CannotCreateUserDefaultsError(suiteName: suiteName)
        }
        self.userDefaults = userDefaults
    }
    
    public func entryForKey(_ key: String) throws -> PlistEntry? {
        if let object = userDefaults.object(forKey: key) {
            return try PlistEntry.create(fromAny: object)
        }
        return nil
    }
    
    public func set(entry: PlistEntry?, key: String) {
        userDefaults.setValue(entry?.toPlistObject(), forKey: key)
    }
    
    public func removeEntryForKey(_ key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
