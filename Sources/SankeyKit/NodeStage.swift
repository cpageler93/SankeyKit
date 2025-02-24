//
//  NodeStage.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 24.02.25.
//

public struct NodeStage: Identifiable, Equatable {
    public var index: Int
    public var nodeIDs: [Node.ID]

    public var id: Int { index }
}
