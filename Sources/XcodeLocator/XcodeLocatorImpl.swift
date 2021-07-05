import FileSystem
import Foundation
import PathLib
import PlistLib
import XcodeLocatorModels

public final class XcodeLocatorImpl: XcodeLocator {
    private let fileSystem: FileSystem
    
    public init(
        fileSystem: FileSystem
    ) {
        self.fileSystem = fileSystem
    }
    
    public func discoverXcodes() throws -> [DiscoveredXcode] {
        let applicationsFolder = try fileSystem.localApplicationsFolder()
        let enumerator = fileSystem.contentEnumerator(forPath: applicationsFolder, style: .shallow)
        
        var discoveredXcodes = [DiscoveredXcode]()
        
        try enumerator.each { path in
            guard path.lastComponent.contains("Xcode") || path.lastComponent.contains("xcode") else {
                return
            }
            let plistPath = path.appending(components: ["Contents", "Info.plist"])
            guard fileSystem.exists(path: plistPath) else {
                return
            }
            
            let plist = try Plist.create(fromData: Data(contentsOf: plistPath.fileUrl, options: .mappedIfSafe))
            guard try plist.root.plistEntry.entry(forKey: "CFBundleIdentifier").stringValue() == "com.apple.dt.Xcode" else {
                return
            }
            let shortVersion = try plist.root.plistEntry.entry(forKey: "CFBundleShortVersionString").stringValue()
            discoveredXcodes.append(
                DiscoveredXcode(
                    path: path,
                    shortVersion: shortVersion
                )
            )
        }
        
        return discoveredXcodes
    }
}
