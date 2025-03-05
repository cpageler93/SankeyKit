//
//  Sankey.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 22.02.25.
//

import SwiftUI

public struct Sankey: Equatable, Hashable {
    public private(set) var nodes: [Node] = []
    public private(set) var flows: [Flow] = []

    public private(set) var stages: [NodeStage] = []

    // MARK: - Nodes

    /// Checks if node with title exists or creates new one with title
    /// - Parameter title: Title of node
    /// - Returns: ID of existing or created node
    @discardableResult
    public mutating func addNodeIfNeeded(title: String) -> Node.ID {
        if let first = nodes.first(where: { $0.title == title }) {
            return first.id
        } else {
            let newNode = Node(id: .init(), title: title)
            nodes.append(newNode)
            updateNodeStages()
            return newNode.id
        }
    }

    /// - Returns: Node with given id
    public func node(id: Node.ID) -> Node? {
        nodes.first(where: { $0.id == id })
    }

    /// - Returns: Node.ID from node with given title
    public func nodeID(title: String) -> Node.ID? {
        nodes.first(where: { $0.title == title })?.id
    }

    public mutating func setNodeColor(nodeID: Node.ID, color: Color) {
        guard let index = nodes.firstIndex(where: { $0.id == nodeID }) else { return }
        nodes[index].color = color
    }

    // MARK: - Flows

    /// Adds a from from node `from` to `to` with given flow value `value`
    @discardableResult
    public mutating func addFlow(from: Node.ID, value: FlowValue, to: Node.ID, color: Color? = nil) -> Flow {
        let flow = Flow(id: .init(), source: from, target: to, value: value, color: color)
        flows.append(flow)
        updateNodeStages()
        return flow
    }

    public mutating func setFlowColor(flowID: Flow.ID, color: Color) {
        guard let index = flows.firstIndex(where: { $0.id == flowID }) else { return }
        flows[index].color = color
    }

    /// - Returns: All starting node ids
    public func startingNodeIDs() -> [Node.ID] {
        nodes
            .map { $0.id }
            .filter { nodeID in
                isStartingNode(nodeID: nodeID)
            }
    }

    /// - Returns: True if given node id is a starting node
    public func isStartingNode(nodeID: Node.ID) -> Bool {
        flows
            .filter { flow in flow.target == nodeID }
            .isEmpty
    }

    /// - Returns: All flows where source node is `sourceNodeID`
    public func flows(sourceNodeID: Node.ID) -> [Flow] {
        flows.filter { $0.source == sourceNodeID }
    }

    /// - Returns: All flows where target node is `targetNodeID`
    public func flows(targetNodeID: Node.ID) -> [Flow] {
        flows.filter { $0.target == targetNodeID }
    }

    // MARK: - Values

    /// Calculates value for node
    /// - Parameter nodeID: node id
    /// - Returns: Value for the given node id
    public func valueForNode(id nodeID: Node.ID) -> Double {
        let sourceValue = sourceValueForNode(id: nodeID)
        let targetValue = targetValueForNode(id: nodeID)
        return max(sourceValue, targetValue)
    }

    public func valueForFlow(flow: Flow) -> Double {
        switch flow.value {
        case let .double(double):
            return double
        case .unusedRemainderFromSource:
            return resolveValue(for: flow.target, in: flow)
        case .unsourcedAmoutFromTarget:
            return resolveValue(for: flow.source, in: flow)
        }
    }

    private func sourceValueForNode(id nodeID: Node.ID) -> Double {
        flows(sourceNodeID: nodeID).map { resolveValue(for: nodeID, in: $0) }.reduce(0, +)
    }

    private func targetValueForNode(id nodeID: Node.ID) -> Double {
        flows(targetNodeID: nodeID).map { resolveValue(for: nodeID, in: $0) }.reduce(0, +)
    }

    private func resolveValue(for nodeID: Node.ID, in flow: Flow) -> Double {
        switch flow.value {
        case let .double(double):
            return double
        case .unusedRemainderFromSource:
            let base = node(id: nodeID)!
            let source = node(id: flow.source)!
            let target = node(id: flow.target)!
            if base.id == target.id {
                let sourceValue = sourceValueForNode(id: source.id)
                let targetValue = targetValueForNode(id: source.id)
                let resolved = targetValue - sourceValue
                return resolved
            } else {
                return 0
            }
        case .unsourcedAmoutFromTarget:
            let base = node(id: nodeID)!
            let source = node(id: flow.source)!
            let target = node(id: flow.target)!
            if base.id == source.id {
                return sourceValueForNode(id: target.id)
            } else {
                return 0
            }
        }
    }

    // MARK: - Stages

    private mutating func updateNodeStages() {
        var result: [NodeStage] = []
        for node in nodes {
            let stage = stageIndexFor(nodeID: node.id)
            if let index = result.firstIndex(where: { $0.index == stage }) {
                var existingStage = result[index]
                existingStage.nodeIDs.append(node.id)
                result[index] = existingStage
            } else {
                let newStage = NodeStage(index: stage, nodeIDs: [node.id])
                result.append(newStage)
            }
        }
        stages = result
    }

    /// Calculates stage for node
    /// - Parameter nodeID: node
    /// - Returns: stage for given node id
    private func stageIndexFor(nodeID: Node.ID) -> Int {
        // Starting nodes are on stage 0
        if isStartingNode(nodeID: nodeID) {
            return 0
        }
        // Iterate over all flows of the node and sum up stages
        let flows = flows(targetNodeID: nodeID)
        let maxStageFromSource = flows.map { stageIndexFor(nodeID: $0.source) }.max() ?? 0
        return maxStageFromSource + 1
    }

    public func findNodeStage(for node: Node.ID) -> NodeStage? {
        stages.first(where: { $0.nodeIDs.contains(node)} )
    }

    public func valueForStage(stage: NodeStage) -> Double {
        stage.nodeIDs
            .map { valueForNode(id: $0) }
            .reduce(0.0, +)
    }

    public func maximumValueForStages() -> Double? {
        stages.map { valueForStage(stage: $0) }.max()
    }
}
