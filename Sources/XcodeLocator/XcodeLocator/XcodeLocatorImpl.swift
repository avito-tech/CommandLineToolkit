import FileSystem
import Foundation
import PathLib
import PlistLib
import XcodeLocatorModels

// If `ApplicationPathsProvider` fails to provide paths,
// `discoverXcodes()` will throw error. However, if some unexpected
// files will be in applications paths, it will not throw error.
// For example, something that looks like application, but without
// bundle indentifier.
public final class XcodeLocatorImpl: XcodeLocator {
    private struct PathAndPlist {
        let path: AbsolutePath
        let infoPlist: Plist
    }
    
    private let applicationPathsProvider: ApplicationPathsProvider
    private let xcodeApplicationVerifier: XcodeApplicationVerifier
    private let applicationPlistReader: ApplicationPlistReader
    
    public init(
        applicationPathsProvider: ApplicationPathsProvider,
        xcodeApplicationVerifier: XcodeApplicationVerifier,
        applicationPlistReader: ApplicationPlistReader
    ) {
        self.applicationPathsProvider = applicationPathsProvider
        self.xcodeApplicationVerifier = xcodeApplicationVerifier
        self.applicationPlistReader = applicationPlistReader
    }
    
    public func discoverXcodes() throws -> [DiscoveredXcode] {
        try applicationPathsAndPlists().filter { pathAndPlist in
            xcodeApplicationVerifier.isXcodeApplicaton(
                infoPlist: pathAndPlist.infoPlist
            )
        }.compactMap { pathAndPlist in
            discoverXcode(pathAndPlist: pathAndPlist)
        }
    }
    
    private func applicationPathsAndPlists() throws -> [PathAndPlist] {
        try applicationPathsProvider.applicationPaths().compactMap { applicationPath in
            try? PathAndPlist(
                path: applicationPath,
                infoPlist: applicationPlistReader.applicationPlist(
                    pathToApplication: applicationPath
                )
            )
        }
    }
    
    private func discoverXcode(pathAndPlist: PathAndPlist) -> DiscoveredXcode? {
        do {
            let shortVersion = try pathAndPlist.infoPlist
                .root
                .plistEntry
                .entry(forKey: "CFBundleShortVersionString")
                .stringValue()
            
            return DiscoveredXcode(
                path: pathAndPlist.path,
                shortVersion: shortVersion
            )
        } catch {
            return nil
        }
    }
}
