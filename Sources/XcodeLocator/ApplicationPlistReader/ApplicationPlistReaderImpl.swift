import PathLib
import CLTExtensions
import PlistLib
import Foundation

public final class ApplicationPlistReaderImpl: ApplicationPlistReader {
    public init() {
    }
    
    public func applicationPlist(pathToApplication: AbsolutePath) throws -> Plist {
        let plistPath = pathToApplication
            .appending("Contents/Info.plist")
        
        return try Plist.create(
            fromData: Data(
                contentsOf: plistPath.fileUrl,
                options: .mappedIfSafe
            )
        )
    }
}
