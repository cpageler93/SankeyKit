//
//  FlowPointsPath.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

import CoreGraphics

protocol FlowPointsPath {
    init()
    func move(to point: CGPoint)
    func line(to point: CGPoint)
    func curve(to point: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint)
    func close()
}

extension FlowPoints {
    func path<T: FlowPointsPath>(using path: T.Type) -> T {
        let path = T()
        for (index, flowPoint) in points.enumerated() {
            if index == 0 {
                path.move(to: flowPoint.point)
            } else {
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
        }
        path.close()
        return path
    }
}
