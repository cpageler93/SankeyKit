//
//  SankeyMaticString.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 22.02.25.
//

import SwiftUI
import RegexBuilder

public struct SankeyMaticString {
    public var string: String
}

extension SankeyMaticString: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(string: value)
    }
}

extension SankeyMaticString: SankeyInitializable {
    public func initSankey() throws -> Sankey {
        var result = Sankey()
        try initNodesAndFlows(sankey: &result)
        try initColors(sankey: &result)
        return result
    }

    private func initNodesAndFlows(sankey: inout Sankey) throws {
        //               1         2              3       4
        //           (node 1)   (value)       (node 2) (color)
        let regex = /([^#\n]*)\[([0-9.,*?]*)\]([^#\n]*)([#a-zA-Z0-9.]*)/
        let matches = string.matches(of: regex)
        for match in matches {
            guard !match.output.0.starts(with: "//") else { continue }

            let sourceString = match.output.1.trimmingCharacters(in: .whitespaces)
            let valueString = match.output.2
            let targetString = match.output.3.trimmingCharacters(in: .whitespaces)
            let flowColorString = match.output.4.trimmingCharacters(in: .whitespaces)

            // Add nodes and retrieve ids
            let sourceNodeID = sankey.addNodeIfNeeded(title: sourceString)
            let targetNodeID = sankey.addNodeIfNeeded(title: targetString)
            // Parse flow value
            let value = try FlowValue(stringValue: String(valueString))
            let color: Color? = flowColorString.isEmpty ? nil : Color(sankeyHex: flowColorString)

            // Add flow
            sankey.addFlow(from: sourceNodeID, value: value, to: targetNodeID, color: color)
        }
    }

    private func initColors(sankey: inout Sankey) throws {
        // mlm: multiline mode
        //                   1         2          3              4
        //           mlm   (node)   (color)   (<< or >>)     (<< or >>)
        let regex = /(?m)^:([^#\n]*)([^\n><]*)([<|>]{2}|)[ ]*([<|>]{2}|)/
        let matches = string.matches(of: regex)
        for match in matches {
            guard !match.output.0.starts(with: "//") else { continue }

            let nodeName = match.output.1.trimmingCharacters(in: .whitespaces)
            let colorString = match.output.2.trimmingCharacters(in: .whitespaces)
            let fromToFlow1 = match.output.3.trimmingCharacters(in: .whitespaces)
            let fromToFlow2 = match.output.4.trimmingCharacters(in: .whitespaces)

            colorizeNode(
                name: nodeName,
                colorString: colorString,
                colorizeFlowsFromNode: [fromToFlow1, fromToFlow2].contains(">>"),
                colorizeFlowsToNode: [fromToFlow1, fromToFlow2].contains("<<"),
                in: &sankey
            )
        }
    }

    private func colorizeNode(
        name: String,
        colorString: String,
        colorizeFlowsFromNode: Bool,
        colorizeFlowsToNode: Bool,
        in sankey: inout Sankey
    ) {
        guard let nodeID = sankey.nodeID(title: name) else { return }
        guard let color = Color(sankeyHex: colorString) else { return }
        sankey.setNodeColor(nodeID: nodeID, color: color)

        if colorizeFlowsFromNode {
            for flow in sankey.flows(sourceNodeID: nodeID) {
                sankey.setFlowColor(flowID: flow.id, color: color)
            }
        }

        if colorizeFlowsToNode {
            for flow in sankey.flows(targetNodeID: nodeID) {
                sankey.setFlowColor(flowID: flow.id, color: color)
            }
        }
    }
}
