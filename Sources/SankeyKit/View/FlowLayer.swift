//
//  FlowLayer.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 13.03.25.
//

import QuartzCore
import SwiftUI

#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

class FlowLayer: CAShapeLayer {
    init(flow: Flow, flowPoints: FlowPoints, settings: SankeySettings) {
        let fillColor = (flow.color.map { NativeColor($0) } ?? NativeColor.gray)
            .withAlphaComponent(settings.flowOpacity)
            .cgColor
        let path = flowPoints.path(using: NativeBezierPath.self)

        super.init()

        self.path = path.cgPath
        self.fillColor = fillColor
        self.lineWidth = 1
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
