//
//  SankeyCalculator.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

import CoreGraphics

class SankeyCalculator {
    private let sankey: Sankey
    private let settings: SankeySettings
    private let rect: CGRect

    private(set) var nodeRects: [Node.ID: CGRect] = [:]
    private(set) var flowPoints: [Flow.ID: FlowPoints] = [:]
    let drawingRect: CGRect
    private let maximumValueForStages: Double

    /// Spacing between nodes of a stage in pt
    private var nodeSpacing: Double = 0

    init(sankey: Sankey, settings: SankeySettings, rect: CGRect) {
        self.sankey = sankey
        self.settings = settings
        self.rect = rect

        self.drawingRect = rect.inset(by: .init(sankeyInsets: settings.insets))
        self.maximumValueForStages = sankey.maximumValueForStages() ?? 0

        calculate()
    }

    private func calculate() {
        calculateNodeRects()
        calculateNodeSpacing()
        applyNodeSpacing()
        calculateNodeHeightCenter()

        calculateFlowPoints()
        calculateFlowPointsCurviness()
    }

    private func calculateNodeRects() {
        for node in sankey.nodes {
            calculateNodeRect(nodeID: node.id)
        }
    }

    private func calculateNodeHeightCenter() {
//        let drawingRectWithNodeHeight = drawingRect.size.height * settings.nodeHeight
//        let offset = (drawingRect.size.height - drawingRectWithNodeHeight) / 2
//        for (nodeID, nodeRect) in nodeRects {
//            var centeredNodeRect = nodeRect
//            centeredNodeRect.origin.y += offset
//            nodeRects[nodeID] = centeredNodeRect
//        }

        for stage in sankey.stages {

        }
    }

    private func calculateNodeSpacing() {
        guard let maxNumberOfNodesInStage = sankey.stages.map({ $0.nodeIDs.count }).max() else { return }
        let numberOfSpacing = maxNumberOfNodesInStage - 1
        guard numberOfSpacing > 0 else { return }

        let drawingRectWithNodeHeight = drawingRect.size.height * settings.nodeHeight
        let totalSpacing = drawingRect.size.height - drawingRectWithNodeHeight
        let totalSpacingWithSetting = totalSpacing * settings.nodeSpacing
        nodeSpacing = totalSpacingWithSetting / Double(numberOfSpacing)
    }

    private func applyNodeSpacing() {
        for stage in sankey.stages {
            for (index, nodeID) in stage.nodeIDs.enumerated() {
                guard var nodeRectWithSpacing = nodeRects[nodeID] else { continue }
                let offset = nodeSpacing * Double(index)
                nodeRectWithSpacing.origin.y += offset
                nodeRects[nodeID] = nodeRectWithSpacing
            }
        }
    }

    @discardableResult
    private func calculateNodeRect(nodeID: Node.ID) -> CGRect? {
        if let cachedNodeRect = nodeRects[nodeID] { return cachedNodeRect }
        guard let stage = sankey.findNodeStage(for: nodeID) else { return nil }
        guard let indexOfStage = sankey.stages.firstIndex(of: stage) else { return nil }
        guard let indexOfNodeInStage = stage.nodeIDs.firstIndex(of: nodeID) else { return nil }

        let value = sankey.valueForNode(id: nodeID)
        let nodeHeight = height(for: value)
        let nodeStageSpacing = (drawingRect.size.width - settings.nodeWidth) / Double(sankey.stages.count - 1)

        var nodeOffset: CGPoint = .init(
            x: drawingRect.origin.x + (nodeStageSpacing * Double(indexOfStage)),
            y: drawingRect.origin.y
        )

        // Calculate rects for nodes in same stage, above `nodeID`
        var upperSiblingIndex = indexOfNodeInStage - 1
        var siblingOffset: CGPoint = .zero
        while upperSiblingIndex >= 0 {
            let siblingNodeID = stage.nodeIDs[upperSiblingIndex]
            let siblingRect = calculateNodeRect(nodeID: siblingNodeID) ?? .zero
            siblingOffset.y += siblingRect.size.height
            upperSiblingIndex -= 1
        }

//        // Calculate offset for source of first flow where node is the target
//        var targetFlowOffset: CGPoint = .zero
//        if let firstTargetFlow = sankey.flows(targetNodeID: nodeID).first {
//            if let sourceNodeRect = rectFor(nodeID: firstTargetFlow.source, rect: rect) {
//                targetFlowOffset.y = sourceNodeRect.origin.y - inset.top
//            }
//        }
//

        // Calculate node spacing offsets

        // Add offsets
        nodeOffset.y += siblingOffset.y
//        nodeOffset.y += // + targetFlowOffset.y

        let result = CGRect(
            x: nodeOffset.x,
            y: nodeOffset.y,
            width: settings.nodeWidth,
            height: nodeHeight
        )
        nodeRects[nodeID] = result
        return result
    }

    private func calculateFlowPoints() {
        for flow in sankey.flows {
            calculateFlowPoints(flow: flow)
        }
    }

    @discardableResult
    private func calculateFlowPoints(flow: Flow) -> FlowPoints? {
        if let cachedFlowPoints = flowPoints[flow.id] { return cachedFlowPoints }
        guard let sourceRect = calculateNodeRect(nodeID: flow.source) else { return nil }
        guard let targetRect = calculateNodeRect(nodeID: flow.target) else { return nil }

        let flowValue = sankey.valueForFlow(flow: flow)
        let flowHeight = height(for: flowValue)

        func heightAboveFlow(in flows: [Flow]) -> Double {
            guard let indexOfFlow = flows.firstIndex(of: flow) else { return 0 }
            var result = 0.0

            var upperSiblingIndex = indexOfFlow - 1
            while upperSiblingIndex >= 0 {
                let siblingFlow = flows[upperSiblingIndex]
                let siblingValue = sankey.valueForFlow(flow: siblingFlow)
                let siblingHeight = height(for: siblingValue)
                result += siblingHeight
                upperSiblingIndex -= 1
            }

            return result
        }

        let sourceFlowOffset = heightAboveFlow(in: sankey.flows(sourceNodeID: flow.source))
        let targetFlowOffset = heightAboveFlow(in: sankey.flows(targetNodeID: flow.target))

        let result = FlowPoints(points: [
            .init(point: sourceRect.topRight.moving(y: sourceFlowOffset)),
            .init(point: targetRect.topLeft.moving(y: targetFlowOffset)),
            .init(point: targetRect.topLeft.moving(y: flowHeight).moving(y: targetFlowOffset)),
            .init(point: sourceRect.topRight.moving(y: flowHeight).moving(y: sourceFlowOffset))
        ])
        flowPoints[flow.id] = result
        return result
    }

    private func calculateFlowPointsCurviness() {
        for (flowID, flowPoints) in flowPoints {
            guard flowPoints.points.count == 4 else { continue }

            var flowPoints = flowPoints

            // calculate curviness for line from source to target
            let curveToPoint1 = calculateCurvedPoint(
                from: flowPoints.points[0],
                to: flowPoints.points[1],
                curviness: settings.flowCurviness
            )
            flowPoints.points[1] = curveToPoint1

            // calculate curviness for line back from target to source
            let curveToPoint3 = calculateCurvedPoint(
                from: flowPoints.points[2],
                to: flowPoints.points[3],
                curviness: settings.flowCurviness
            )
            flowPoints.points[3] = curveToPoint3

            self.flowPoints[flowID] = flowPoints
        }
    }

    private func calculateCurvedPoint(from: FlowPoint, to: FlowPoint, curviness: Double) -> FlowPoint {
        var result = to

        var controlPoint1 = from.point.interpolated(to: to.point, t: curviness)
        controlPoint1.y = from.point.y

        var controlPoint2 = to.point.interpolated(to: from.point, t: curviness)
        controlPoint2.y = to.point.y

        result.controlPoints = .init(
            controlPoint1: controlPoint1,
            controlPoint2: controlPoint2
        )

        return result
    }

    private func height(for value: Double) -> Double {
        (drawingRect.size.height * settings.nodeHeight) * value / maximumValueForStages
    }
}
