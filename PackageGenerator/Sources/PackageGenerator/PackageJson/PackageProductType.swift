import Foundation

public enum PackageProductType: String, Codable, Hashable {
    case executable
    case library
    case dynamicLibrary
}
