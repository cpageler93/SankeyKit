//
//  SankeyView.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 24.02.25.
//

import SwiftUI

public struct SankeyView: View {
    @State public var sankey: Sankey
    @State private var canvasSize: CGSize = .zero

    public var inset: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    public var nodeWidth: Double = 30

    public var body: some View {
        Canvas(opaque: true, colorMode: .linear, rendersAsynchronously: true) { context, size in
            let rect = rectWithInset(size: size)
            context.fill(Rectangle().path(in: rect), with: .color(.red.opacity(0.5)))

            for stage in sankey.stages {
                for nodeID in stage.nodeIDs {
                    guard let nodeRect = rectFor(nodeID: nodeID, rect: rect) else {
                        continue
                    }
                    let nodePath = Rectangle().path(in: nodeRect)
                    context.stroke(nodePath, with: .color(.green), lineWidth: 2)

                    let node = sankey.node(id: nodeID)
                    context.draw(Text(node?.title ?? "title"), in: nodeRect)
                }
            }
        }
    }

    private func rectWithInset(size: CGSize) -> CGRect {
        .init(
            origin: .init(x: inset.leading, y: inset.top),
            size: .init(
                width: size.width - inset.leading - inset.trailing,
                height: size.height - inset.top - inset.bottom
            )
        )
    }

    private func rectFor(
        nodeID: Node.ID,
        rect: CGRect
    ) -> CGRect? {
        guard let stage = sankey.findNodeStage(for: nodeID) else { return nil }
        guard let indexOfStage = sankey.stages.firstIndex(of: stage) else { return nil }
        guard let nodeIndexInStage = stage.nodeIDs.firstIndex(of: nodeID) else { return nil }
        let maxValue = sankey.maximumValueForStages() ?? 0
        let nodeValue = sankey.valueForNode(id: nodeID)
        let nodeHeight = rect.size.height * nodeValue / maxValue
        let nodeStepSize = (rect.size.width - nodeWidth) / Double(sankey.stages.count - 1)

        var nodeOffset: CGPoint = .init(
            x: rect.origin.x + (nodeStepSize * Double(indexOfStage)),
            y: rect.origin.y
        )

        // calculate rects for nodes in same stage, above `nodeID`
        var upperSiblingIndex = nodeIndexInStage - 1
        var sibblingOffset: CGPoint = .zero
        while upperSiblingIndex >= 0 {
            let sibblingNodeID = stage.nodeIDs[upperSiblingIndex]
            let sibblingRect = rectFor(nodeID: sibblingNodeID, rect: rect) ?? .zero
            sibblingOffset.y += sibblingRect.size.height
            upperSiblingIndex -= 1
        }

        var targetFlowOffset: CGPoint = .zero
        if let firstTargetFlow = sankey.flows(targetNodeID: nodeID).first {
            let rectForFirstTargetFlowSource = rectFor(nodeID: firstTargetFlow.source, rect: rect)
            targetFlowOffset.y = rect.origin.y + rect.size.height
        }

        print("Node target offset \(targetFlowOffset.y)")

        // Add sibbling offset
        nodeOffset.y += sibblingOffset.y

        return .init(
            x: nodeOffset.x,
            y: nodeOffset.y,
            width: nodeWidth,
            height: nodeHeight
        )
    }
}

#Preview {
    let sankey = (try? ("""
    a [2] 1
    a [2] 2
    b [2] 1
    c [2] 2
    1 [1] x
    1 [3] y
    y [1] i
    y [1] j
    y [1] k
    """ as SankeyMaticString).initSankey()) ?? .init()

    SankeyView(
        sankey: sankey,
        inset: .init(top: 10, leading: 10, bottom: 10, trailing: 10)
    )
}
