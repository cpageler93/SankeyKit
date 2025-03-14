//
//  NodeLayer.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 11.03.25.
//

import QuartzCore
import SwiftUI

#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

class NodeLayer: CAShapeLayer {
    init(node: Node, rect: CGRect, index: Int, settings: SankeySettings) {
        let nodeFillColor = node.color.map { NativeColor($0) }
        let settingsColor = Color(hex: settings.nodeColors[index % settings.nodeColors.count])
            .map { NativeColor($0) }
        let defaultColor = NativeColor.gray
        let fillColor = nodeFillColor ?? settingsColor ?? defaultColor

        super.init()

        self.path = rect.path(
            using: NativeBezierPath.self,
            cornerRadius: settings.nodeCornerRadius
        ).cgPath
        self.fillColor = fillColor.cgColor
        self.lineWidth = 1
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CGRect {
    func path<T: PathBuilder>(using pathBuilder: T.Type, cornerRadius: SankeyCornerRadius) -> T {
        let pathBuilder = T()
        pathBuilder.move(to: topCenter)

        // Top right corner or line
        if cornerRadius.topRight > 0 {
            pathBuilder.arc(
                withCenter: topRight
                    .moving(x: -cornerRadius.topRight)
                    .moving(y: cornerRadius.topRight),
                radius: cornerRadius.topRight,
                startAngle: 270,
                endAngle: 0
            )
        } else {
            pathBuilder.line(to: topRight)
        }

        // Bottom right corner or line
        if cornerRadius.bottomRight > 0 {
            pathBuilder.arc(
                withCenter: bottomRight
                    .moving(x: -cornerRadius.bottomRight)
                    .moving(y: -cornerRadius.bottomRight),
                radius: cornerRadius.bottomRight,
                startAngle: 0,
                endAngle: 90
            )
        } else {
            pathBuilder.line(to: bottomRight)
        }

        // Bottom left corner or line
        if cornerRadius.bottomLeft > 0 {
            pathBuilder.arc(
                withCenter: bottomLeft
                    .moving(x: cornerRadius.bottomLeft)
                    .moving(y: -cornerRadius.bottomLeft),
                radius: cornerRadius.bottomLeft,
                startAngle: 90,
                endAngle: 180
            )
        } else {
            pathBuilder.line(to: bottomLeft)
        }

        // Top left corner or line
        if cornerRadius.topLeft > 0 {
            pathBuilder.arc(
                withCenter: topLeft
                    .moving(x: cornerRadius.topLeft)
                    .moving(y: cornerRadius.topLeft),
                radius: cornerRadius.topLeft,
                startAngle: 180,
                endAngle: 270
            )
        } else {
            pathBuilder.line(to: topLeft)
        }

        pathBuilder.close()
        return pathBuilder
    }
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
