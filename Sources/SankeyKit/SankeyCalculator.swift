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
        calculateStageCenterPosition()

        calculateFlowPoints()
        calculateFlowPointsInsets()
        calculateFlowPointsCurviness()
    }

    private func calculateNodeRects() {
        for node in sankey.nodes {
            calculateNodeRect(nodeID: node.id)
        }
    }

    private func calculateStageCenterPosition() {
        for stage in sankey.stages {
            var stageSize = stage.nodeIDs
                .compactMap { nodeRects[$0] }
                .map { $0.size }
                .reduce(CGSize.zero) { partialResult, size in
                    var result = partialResult
                    result.width += size.width
                    result.height += size.height
                    return result
                }
            let stageNodeSpacing = nodeSpacing * Double(stage.nodeIDs.count - 1)
            stageSize.height += stageNodeSpacing
            stageSize.width += stageNodeSpacing

            let offset = CGSize(
                width: ((drawingRect.size.width) - stageSize.width) / 2,
                height: ((drawingRect.size.height) - stageSize.height) / 2
            )

            for nodeId in stage.nodeIDs {
                guard var nodeRect = nodeRects[nodeId] else { continue }
                switch settings.axis {
                case .horizontal:
                    nodeRect.origin.y += offset.height
                case .vertical:
                    nodeRect.origin.x += offset.width
                }
                nodeRects[nodeId] = nodeRect
            }
        }
    }

//    private func calculateNodeHeightCenter() {
////        let drawingRectWithNodeHeight = drawingRect.size.height * settings.nodeHeight
////        let offset = (drawingRect.size.height - drawingRectWithNodeHeight) / 2
////        for (nodeID, nodeRect) in nodeRects {
////            var centeredNodeRect = nodeRect
////            centeredNodeRect.origin.y += offset
////            nodeRects[nodeID] = centeredNodeRect
////        }
//
//        for stage in sankey.stages {
//
//        }
//    }

    private func calculateNodeSpacing() {
        guard let maxNumberOfNodesInStage = sankey.stages.map({ $0.nodeIDs.count }).max() else { return }
        let numberOfSpacing = maxNumberOfNodesInStage - 1
        guard numberOfSpacing > 0 else { return }

        let drawingRectSizeWithNodeScale = CGSize(
            width: drawingRect.size.width * settings.nodeScale,
            height: drawingRect.size.height * settings.nodeScale
        )
        let totalSpacingSize = CGSize(
            width: drawingRect.size.width - drawingRectSizeWithNodeScale.width,
            height: drawingRect.size.height - drawingRectSizeWithNodeScale.height
        )
        let totalSpacingSizeWithSetting = CGSize(
            width: totalSpacingSize.width * settings.nodeSpacing,
            height: totalSpacingSize.height * settings.nodeSpacing
        )

        switch settings.axis {
        case .horizontal:
            nodeSpacing = totalSpacingSizeWithSetting.height / Double(numberOfSpacing)
        case .vertical:
            nodeSpacing = totalSpacingSizeWithSetting.width / Double(numberOfSpacing)
        }
    }

    private func applyNodeSpacing() {
        for stage in sankey.stages {
            for (index, nodeID) in stage.nodeIDs.enumerated() {
                guard var nodeRectWithSpacing = nodeRects[nodeID] else { continue }
                let offset = nodeSpacing * Double(index)
                switch settings.axis {
                case .horizontal:
                    nodeRectWithSpacing.origin.y += offset
                case .vertical:
                    nodeRectWithSpacing.origin.x += offset
                }
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

        // Calculate spacing between node stages for both axis
        let nodeStageSpacing = CGSize(
            width: (drawingRect.size.width - settings.nodeThickness) / Double(sankey.stages.count - 1),
            height: (drawingRect.size.height - settings.nodeThickness) / Double(sankey.stages.count - 1)
        )

        // Calculate node offset
        var nodeOffset: CGPoint = .init(
            x: drawingRect.origin.x,
            y: drawingRect.origin.y
        )
        switch settings.axis {
        case .horizontal:
            nodeOffset.x += (nodeStageSpacing.width * Double(indexOfStage))
        case .vertical:
            nodeOffset.y += (nodeStageSpacing.height * Double(indexOfStage))
        }

        // Calculate rects for nodes in same stage, above `nodeID`
        var upperSiblingIndex = indexOfNodeInStage - 1
        var siblingOffset: CGPoint = .zero
        while upperSiblingIndex >= 0 {
            let siblingNodeID = stage.nodeIDs[upperSiblingIndex]
            let siblingRect = calculateNodeRect(nodeID: siblingNodeID) ?? .zero
            switch settings.axis {
            case .horizontal:
                siblingOffset.y += siblingRect.size.height
            case .vertical:
                siblingOffset.x += siblingRect.size.width
            }

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

        // Add offsets
        nodeOffset.move(offset: siblingOffset)

        // Value of node, to calculate width or height
        let value = sankey.valueForNode(id: nodeID)

        // Create node rect depending on axis
        let result = CGRect(
            x: nodeOffset.x,
            y: nodeOffset.y,
            width: settings.axis == .horizontal ? settings.nodeThickness : width(for: value),
            height: settings.axis == .horizontal ? height(for: value) : settings.nodeThickness
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

        func sizeAboveFlow(in flows: [Flow]) -> CGSize {
            guard let indexOfFlow = flows.firstIndex(of: flow) else { return .zero }
            var result = CGSize.zero

            var upperSiblingIndex = indexOfFlow - 1
            while upperSiblingIndex >= 0 {
                let siblingFlow = flows[upperSiblingIndex]
                let siblingValue = sankey.valueForFlow(flow: siblingFlow)
                result.height += height(for: siblingValue)
                result.width += width(for: siblingValue)
                upperSiblingIndex -= 1
            }

            return result
        }

        let flowValue = sankey.valueForFlow(flow: flow)
        let flowHeight = height(for: flowValue)
        let flowWidth = width(for: flowValue)
        let sourceFlowOffset = sizeAboveFlow(in: sankey.flows(sourceNodeID: flow.source))
        let targetFlowOffset = sizeAboveFlow(in: sankey.flows(targetNodeID: flow.target))

        let result: FlowPoints
        switch settings.axis {
        case .horizontal:
            // Horizontal flow starts at the top right point of the source rect, clockwise
            result = FlowPoints(
                firstSourcePoint: .topLeft(sourceRect.topRight.moving(y: sourceFlowOffset.height)),
                firstTargetPoint: .topRight(targetRect.topLeft.moving(y: targetFlowOffset.height)),
                secondTargetPoint: .bottomRight(targetRect.topLeft.moving(y: flowHeight).moving(y: targetFlowOffset.height)),
                secondSourcePoint: .bottomLeft(sourceRect.topRight.moving(y: flowHeight).moving(y: sourceFlowOffset.height))
            )
        case .vertical:
            // Vertical flow starts at the bottom left point of the source rect, counter clockwise
            result = FlowPoints(
                firstSourcePoint: .topLeft(sourceRect.bottomLeft.moving(x: sourceFlowOffset.width)),
                firstTargetPoint: .bottomLeft(targetRect.topLeft.moving(x: targetFlowOffset.width)),
                secondTargetPoint: .bottomRight(targetRect.topLeft.moving(x: flowWidth).moving(x: targetFlowOffset.width)),
                secondSourcePoint: .topRight(sourceRect.bottomLeft.moving(x: flowWidth).moving(x: sourceFlowOffset.width))
            )
        }
        flowPoints[flow.id] = result
        return result
    }

    private func calculateFlowPointsInsets() {
        for (flowID, flowPoints) in flowPoints {
            var flowPoints = flowPoints

            func move(flowPoint: inout FlowPoint) {
                switch flowPoint.position {
                case .topLeft:
                    flowPoint.point.x += settings.flowInsets.leading
                    flowPoint.point.y += settings.flowInsets.top
                case .topRight:
                    flowPoint.point.x -= settings.flowInsets.trailing
                    flowPoint.point.y += settings.flowInsets.top
                case .bottomRight:
                    flowPoint.point.x -= settings.flowInsets.trailing
                    flowPoint.point.y -= settings.flowInsets.bottom
                case .bottomLeft:
                    flowPoint.point.x += settings.flowInsets.leading
                    flowPoint.point.y -= settings.flowInsets.bottom
                }
            }

            move(flowPoint: &flowPoints.firstSourcePoint)
            move(flowPoint: &flowPoints.firstTargetPoint)
            move(flowPoint: &flowPoints.secondTargetPoint)
            move(flowPoint: &flowPoints.secondSourcePoint)

            self.flowPoints[flowID] = flowPoints
        }
    }

    private func calculateFlowPointsCurviness() {
        for (flowID, flowPoints) in flowPoints {
            var flowPoints = flowPoints

            // calculate curviness for line from first source to first target
            let curveToFirstTargetPoint = calculateCurvedPoint(
                from: flowPoints.firstSourcePoint,
                to: flowPoints.firstTargetPoint,
                curviness: settings.flowCurviness
            )
            flowPoints.firstTargetPoint = curveToFirstTargetPoint

            // calculate curviness for line back from second target to second source
            let curveToSecondSourcePoint = calculateCurvedPoint(
                from: flowPoints.secondTargetPoint,
                to: flowPoints.secondSourcePoint,
                curviness: settings.flowCurviness
            )
            flowPoints.secondSourcePoint = curveToSecondSourcePoint

            self.flowPoints[flowID] = flowPoints
        }
    }

    private func calculateCurvedPoint(from: FlowPoint, to: FlowPoint, curviness: Double) -> FlowPoint {
        var result = to

        var controlPoint1 = from.point.interpolated(to: to.point, t: curviness)
        var controlPoint2 = to.point.interpolated(to: from.point, t: curviness)
        switch settings.axis {
        case .horizontal:
            controlPoint1.y = from.point.y
            controlPoint2.y = to.point.y
        case .vertical:
            controlPoint1.x = from.point.x
            controlPoint2.x = to.point.x
        }

        result.controlPoints = .init(
            controlPoint1: controlPoint1,
            controlPoint2: controlPoint2
        )

        return result
    }

    private func height(for value: Double) -> Double {
        (drawingRect.size.height * settings.nodeScale) * value / maximumValueForStages
    }

    private func width(for value: Double) -> Double {
        (drawingRect.size.width * settings.nodeScale) * value / maximumValueForStages
    }
}
