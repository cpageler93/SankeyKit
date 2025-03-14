//
//  FlowPoints.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

import CoreGraphics

struct FlowPoints {
    var firstSourcePoint: FlowPoint
    var firstTargetPoint: FlowPoint
    var secondTargetPoint: FlowPoint
    var secondSourcePoint: FlowPoint
}

struct FlowPoint {
    var point: CGPoint
    var position: FlowPointPosition
    var controlPoints: FlowControlPoints?

    static func topLeft(_ point: CGPoint) -> Self { .init(point: point, position: .topLeft) }
    static func topRight(_ point: CGPoint) -> Self { .init(point: point, position: .topRight) }
    static func bottomRight(_ point: CGPoint) -> Self { .init(point: point, position: .bottomRight) }
    static func bottomLeft(_ point: CGPoint) -> Self { .init(point: point, position: .bottomLeft) }
}

enum FlowPointPosition {
    case topLeft
    case topRight
    case bottomRight
    case bottomLeft
}

struct FlowControlPoints {
    var controlPoint1: CGPoint
    var controlPoint2: CGPoint
}

extension FlowPoints {
    func path<T: PathBuilder>(using path: T.Type) -> T {
        let path = T()

        path.move(to: firstSourcePoint.point)

        func curveOrLineTo(_ flowPoint: FlowPoint) {
            if let controlPoints = flowPoint.controlPoints {
                path.curve(
                    to: flowPoint.point,
                    controlPoint1: controlPoints.controlPoint1,
                    controlPoint2: controlPoints.controlPoint2
                )
            } else {
                path.line(to: flowPoint.point)
            }
        }

        curveOrLineTo(firstTargetPoint)
        curveOrLineTo(secondTargetPoint)
        curveOrLineTo(secondSourcePoint)

        path.close()
        return path
    }
}
