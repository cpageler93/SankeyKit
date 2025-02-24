//
//  SankeyMaticString.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 22.02.25.
//

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
        let regex = /(.*)\[([0-9.,]*)\](.*)/
        let matches = string.matches(of: regex)
        for match in matches {
            let sourceString = match.output.1.trimmingCharacters(in: .whitespaces)
            let valueString = match.output.2
            let targetString = match.output.3.trimmingCharacters(in: .whitespaces)

            // Add nodes and retrieve ids
            let sourceNodeID = result.addNodeIfNeeded(title: sourceString)
            let targetNodeID = result.addNodeIfNeeded(title: targetString)
            // Parse flow value
            let value = try FlowValue(stringValue: String(valueString))

            // Add flow
            result.addFlow(from: sourceNodeID, value: value, to: targetNodeID)
        }
        return result
    }
}
