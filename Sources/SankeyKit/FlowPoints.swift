//
//  FlowPoints.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

import CoreGraphics

struct FlowPoints {
    var points: [FlowPoint]
}

struct FlowPoint {
    var point: CGPoint
    var controlPoints: FlowControlPoints?
}

struct FlowControlPoints {
    var controlPoint1: CGPoint
    var controlPoint2: CGPoint
}

