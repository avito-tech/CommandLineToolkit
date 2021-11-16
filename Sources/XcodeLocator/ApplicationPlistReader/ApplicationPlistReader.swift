import Foundation
import PlistLib
import PathLib

public protocol ApplicationPlistReader {
    func applicationPlist(pathToApplication: AbsolutePath) throws -> Plist
}
