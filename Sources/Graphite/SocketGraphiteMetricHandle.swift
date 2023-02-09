/*
 * Copyright (c) Avito Tech LLC
 */

import Foundation
import Socket
import SocketModels

public final class SocketGraphiteMetricHandler: GraphiteMetricHandler {
    private let graphiteDomain: [String]
    private let socket: Socket
    
    public init(
        graphiteDomain: [String],
        graphiteSocketAddress: SocketAddress
    ) throws {
        self.graphiteDomain = graphiteDomain

        self.socket = try Socket.create(family: .inet, type: .stream, proto: .tcp)
        
        try self.socket.connect(
            to: graphiteSocketAddress.host,
            port: Int32(graphiteSocketAddress.port.value)
        )
    }
    
    public func handle(metric: GraphiteMetric) {
        try? send(
            path: graphiteDomain + metric.components,
            value: metric.value,
            timestamp: metric.timestamp
        )
    }
    
    private func send(path: [String], value: Double, timestamp: Date) throws {
        let entry = try InternalGraphiteMetric(path: path, value: value, timestamp: timestamp)
        
        let data = data(internalMetric: entry)
        try socket.write(from: data)
    }
    
    private func data(internalMetric: InternalGraphiteMetric) -> Data {
        let concatenatedMetricPath = InternalGraphiteMetric.concatenated(path: internalMetric.path)
        let graphiteMetricString = "\(concatenatedMetricPath) \(internalMetric.value) \(UInt64(internalMetric.timestamp.timeIntervalSince1970))\n"
        return Data(graphiteMetricString.utf8)
    }
    
    public func tearDown(timeout: TimeInterval) {
        socket.close()
    }
}

private struct InternalGraphiteMetric {
    let path: [String]
    let value: Double
    let timestamp: Date
    
    enum GraphiteMetricError: Error, CustomStringConvertible {
        case unableToGetData(from: String)
        case incorrectMetricPath(String)
        case incorrectValue(Double)
        
        public var description: String {
            switch self {
            case .unableToGetData(let from):
                return "Unable to convert string '\(from)' to data"
            case .incorrectMetricPath(let value):
                return "The provided metric path is incorrect: \(value)"
            case .incorrectValue(let value):
                return "The provided metric value is incorrect: \(value)"
            }
        }
    }
    
    // swiftlint:disable:next force_try
    private static let pathComponentRegex = try! NSRegularExpression(pattern: "[a-zA-Z0-9-_]+", options: [])
    
    init(path: [String], value: Double, timestamp: Date) throws {
        guard !path.isEmpty else {
            throw GraphiteMetricError.incorrectMetricPath(Self.concatenated(path: path))
        }
        guard value.isFinite else {
            throw GraphiteMetricError.incorrectValue(value)
        }
        for component in path {
            let matches = Self.pathComponentRegex.matches(
                in: component,
                options: [],
                range: NSRange(location: 0, length: component.count)
            )
            guard
                matches.count == 1,
                let firstMatch = matches.first,
                firstMatch.range == NSRange(location: 0, length: component.count)
                else
            {
                throw GraphiteMetricError.incorrectMetricPath(Self.concatenated(path: path))
            }
        }
        
        self.path = path
        self.value = value
        self.timestamp = timestamp
    }
    
    static func concatenated(path: [String]) -> String {
        return path.joined(separator: ".")
    }
}
