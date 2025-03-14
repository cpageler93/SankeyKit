//
//  CGRect+Positions.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

import CoreGraphics

extension CGRect {
    public var topLeft: CGPoint { .init(x: minX, y: minY) }
    public var topRight: CGPoint { .init(x: maxX, y: minY) }
    public var bottomRight: CGPoint { .init(x: maxX, y: maxY) }
    public var bottomLeft: CGPoint { .init(x: minX, y: maxY) }

    public var topCenter: CGPoint { .init(x: midX, y: minY) }
}
