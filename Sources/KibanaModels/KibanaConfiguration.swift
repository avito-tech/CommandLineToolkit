/*
 * Copyright (c) Avito Tech LLC
 */

import Foundation

import CLTTypes

public struct KibanaConfiguration: Codable, Hashable {
    public let endpoints: [URL]
    public let indexPattern: String
    public let authorization: HttpAuthorizationScheme?
    
    public init(
        endpoints: [URL],
        indexPattern: String,
        authorization: HttpAuthorizationScheme?
    ) {
        self.endpoints = endpoints
        self.indexPattern = indexPattern
        self.authorization = authorization
    }
}
