import FileSystem
import FileSystemTestHelpers
import Foundation
import PlistLib
import TestHelpers
import TmpTestHelpers
import XcodeLocator
import XcodeLocatorModels
import XCTest

final class XcodeLocatorTests: XCTestCase {
    lazy var tempFolder = createTempFolder()
    lazy var fileSystem = FakeFileSystem(rootPath: tempFolder.absolutePath)
    
    func test___discovering_xcodes() throws {
        let xcode115Plist = try tempFolder.createFile(components: ["Applications", "Xcode115.app", "Contents"], filename: "Info.plist", contents: try plist(shortVersion: "11.5").data(format: .xml))
        let xcode101Plist = try tempFolder.createFile(components: ["Applications", "Xcode101.app", "Contents"], filename: "Info.plist", contents: try plist(shortVersion: "10.1").data(format: .xml))
        _ = try tempFolder.createDirectory(components: ["Applications", "Xcode123.app"])
        
        fileSystem.propertiesProvider = { DefaultFilePropertiesContainer(path: $0) }
        
        fileSystem.fakeContentEnumerator = { args in
            ShallowFileSystemEnumerator(path: args.path)
        }

        let locator = XcodeLocatorImpl(
            applicationPathsProvider: ApplicationPathsProviderImpl(
                commonlyUsedPathsProvider: fileSystem.commonlyUsedPathsProvider,
                fileSystemEnumeratorFactory: fileSystem
            ),
            xcodeApplicationVerifier: XcodeApplicationVerifierImpl(),
            applicationPlistReader: ApplicationPlistReaderImpl()
        )
        let discoveredXcodes = assertDoesNotThrow {
            try locator.discoverXcodes()
        }
        
        XCTAssertEqual(
            Set(discoveredXcodes),
            Set([
                DiscoveredXcode(path: xcode115Plist.removingLastComponent.removingLastComponent, shortVersion: "11.5"),
                DiscoveredXcode(path: xcode101Plist.removingLastComponent.removingLastComponent, shortVersion: "10.1"),
            ])
        )
    }
    
    private func plist(shortVersion: String) -> Plist {
        Plist(
            rootPlistEntry: .dict(
                [
                    "CFBundleShortVersionString": .string(shortVersion),
                    "CFBundleIdentifier": .string("com.apple.dt.Xcode"),
                ]
            )
        )
    }
}
