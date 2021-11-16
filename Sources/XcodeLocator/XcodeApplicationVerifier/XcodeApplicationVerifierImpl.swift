import PathLib
import Foundation
import PlistLib

public final class XcodeApplicationVerifierImpl: XcodeApplicationVerifier {
    public init() {
    }
    
    public func isXcodeApplicaton(infoPlist: Plist) -> Bool {
        let bundleIdentifier = try? infoPlist
            .root
            .plistEntry
            .entry(forKey: "CFBundleIdentifier")
            .stringValue()
        
        return bundleIdentifier == "com.apple.dt.Xcode"
    }
}
