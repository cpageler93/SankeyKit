//
//  Sankey.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 22.02.25.
//

public struct Sankey {
    public var nodes: [Node] = []
    public var flows: [Flow] = []

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

    public mutating func addFlow(from: Node.ID, to: Node.ID, value: FlowValue) {
        let flow = Flow(source: from, target: to, value: value)
        flows.append(flow)
    }

    /// - Returns: Node IDs for nodes that doesn't have any target
    public func startingNodeIDs() -> [Node.ID] {
        nodes
            .map { $0.id }
            .filter { nodeID in
                flows
                    .filter { flow in flow.target == nodeID }
                    .isEmpty
            }
    }

    public func flows(sourceNodeID: Node.ID) -> [Flow] {
        flows.filter { $0.source == sourceNodeID }
    }

    public func flows(targetNodeID: Node.ID) -> [Flow] {
        flows.filter { $0.target == targetNodeID }
    }


    public func valueForNode(id nodeID: Node.ID) -> Double {
        let sourceValue = sourceValueForNode(id: nodeID)
        let targetValue = targetValueForNode(id: nodeID)
        return max(sourceValue, targetValue)
    }

    private func sourceValueForNode(id nodeID: Node.ID) -> Double {
        flows(sourceNodeID: nodeID).map { resolveValue(for: nodeID, in: $0) }.reduce(0, +)
    }

    private func targetValueForNode(id nodeID: Node.ID) -> Double {
        flows(targetNodeID: nodeID).map { resolveValue(for: nodeID, in: $0) }.reduce(0, +)
    }

    public func resolveValue(for nodeID: Node.ID, in flow: Flow) -> Double {
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
}
