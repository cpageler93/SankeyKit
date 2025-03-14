//
//  SankeyInsets.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

public struct SankeyInsets: Codable {
    public var top: Double
    public var leading: Double
    public var bottom: Double
    public var trailing: Double

    static var zero: Self { .init(top: 0, leading: 0, bottom: 0, trailing: 0) }
}
