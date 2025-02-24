//
//  Flow.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 22.02.25.
//

public struct Flow: Equatable {
    public var source: Node.ID
    public var target: Node.ID
    public var value: FlowValue
}
