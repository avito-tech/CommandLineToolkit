import Foundation
import PlistLib

/// NSUserDefaults allows to store plist entities (NSData, NSString, NSNumber, NSDate, NSArray, or NSDictionary).
/// That's why `Defaults` uses `PlistEntry` objects in its API.
public protocol Defaults {
    
    /// Returns plist object for a given key, or nil.
    /// - Parameter key: defaults key
    func entryForKey(_ key: String) throws -> PlistEntry?
    
    /// Stores plist object under a given key.
    /// - Parameters:
    ///   - entry: plist object to set under the given key. If entry is `nil`, object for the given key will be deleted.
    ///   - key: defaults key
    func set(entry: PlistEntry?, key: String)
    
    /// Removes an stored object for a given key
    /// - Parameter key: defaults key
    func removeEntryForKey(_ key: String)
}
