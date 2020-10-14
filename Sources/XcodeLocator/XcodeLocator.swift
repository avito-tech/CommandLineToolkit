import XcodeLocatorModels

public protocol XcodeLocator {
    func discoverXcodes() throws -> [DiscoveredXcode]
}
