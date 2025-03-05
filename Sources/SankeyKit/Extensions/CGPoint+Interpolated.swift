//
//  CGPoint+Interpolated.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

import CoreGraphics

extension CGPoint {
    public func interpolated(to point: CGPoint, t: CGFloat) -> CGPoint {
        return CGPoint(
            x: x + (point.x - x) * t,
            y: y + (point.y - y) * t
        )
    }
}
