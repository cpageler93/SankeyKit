//
//  PathBuilder.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 12.03.25.
//

import CoreGraphics

protocol PathBuilder {
    init()
    func move(to point: CGPoint)
    func line(to point: CGPoint)
    func curve(to point: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint)
    func arc(
        withCenter center: CGPoint,
        radius: CGFloat,
        startAngle: CGFloat,
        endAngle: CGFloat
    )
    func close()
}

#if canImport(UIKit)
import UIKit

extension UIBezierPath: PathBuilder {
    func line(to point: CGPoint) { addLine(to: point) }

    func curve(to point: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
        addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }

    func arc(withCenter center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
        addArc(
            withCenter: center,
            radius: radius,
            startAngle: startAngle.degreesToRadians,
            endAngle: endAngle.degreesToRadians,
            clockwise: true
        )
    }
}
#else
import AppKit

extension NSBezierPath: PathBuilder {
    func arc(withCenter center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
        appendArc(
            withCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
    }
}
#endif
