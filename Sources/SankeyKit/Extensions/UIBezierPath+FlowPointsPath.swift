//
//  UIBezierPath+FlowPointsPath.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

#if canImport(UIKit)

import UIKit

extension UIBezierPath: FlowPointsPath {
    func line(to point: CGPoint) { addLine(to: point) }

    func curve(to point: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
        addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
}

#endif
