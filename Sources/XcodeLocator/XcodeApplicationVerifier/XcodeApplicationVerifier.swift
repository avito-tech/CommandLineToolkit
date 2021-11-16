import PathLib
import Foundation
import PlistLib

public protocol XcodeApplicationVerifier {
    func isXcodeApplicaton(infoPlist: Plist) -> Bool
}
