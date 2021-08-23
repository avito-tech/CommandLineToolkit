import Foundation

/// Describes a product
public struct PackageProduct: Codable, Hashable {
    
    /// Name of the product
    public let name: String
    
    /// Type of the product
    public let productType: PackageProductType
    
    /// Name of the targets this product consists of.
    public let targets: [String]
    
    public init(name: String, productType: PackageProductType, targets: [String]) {
        self.name = name
        self.productType = productType
        self.targets = targets
    }
}
