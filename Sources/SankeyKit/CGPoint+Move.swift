//
//  CGPoint+Move.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

import CoreGraphics

extension CGPoint {
    public mutating func move(x value: Double) { x += value }
    public mutating func move(y value: Double) { y += value }
    public mutating func move(offset: CGPoint) {
        x += offset.x
        y += offset.y
    }

    public func moving(x value: Double) -> CGPoint {
        var result = self
        result.move(x: value)
        return result
    }

    public func moving(y value: Double) -> CGPoint {
        var result = self
        result.move(y: value)
        return result
    }

    public func moving(offset: CGPoint) -> CGPoint {
        var result = self
        result.move(offset: offset)
        return result
    }
}

