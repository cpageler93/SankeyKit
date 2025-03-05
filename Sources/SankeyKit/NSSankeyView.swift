//
//  NSSankeyView.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

#if canImport(AppKit)

import SwiftUI
import AppKit

public class NSSankeyView: NSView {
    public var sankey: Sankey {
        didSet { layout() }
    }
    public var settings: SankeySettings {
        didSet { layout() }
    }
    public override var isFlipped: Bool { true }

    public init(sankey: Sankey, settings: SankeySettings) {
        self.sankey = sankey
        self.settings = settings

        super.init(frame: .zero)
        self.wantsLayer = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layout() {
        super.layout()

        let calculator = SankeyCalculator(sankey: sankey, settings: settings, rect: bounds)

        // Clear everything
        layer?.sublayers?.forEach { $0.removeFromSuperlayer() }
        layer?.backgroundColor = NSColor.white.cgColor

        for stage in sankey.stages {
            for nodeID in stage.nodeIDs {
                guard let node = sankey.node(id: nodeID) else { continue }
                guard let nodeIndex = sankey.nodes.firstIndex(of: node) else { continue }
                guard let nodeRect = calculator.nodeRects[nodeID] else { continue }

                let nodeFillColor = node.color.map { NSColor($0) }
                let settingsColor = Color(hex: settings.nodeColors[nodeIndex % settings.nodeColors.count])
                    .map { NSColor($0) }
                let defaultColor = NSColor.gray
                let fillColor = nodeFillColor ?? settingsColor ?? defaultColor

                let path = NSBezierPath(rect: nodeRect)
                let shapeLayer = CAShapeLayer()
                shapeLayer.path = path.cgPath
                shapeLayer.fillColor = fillColor.cgColor
                shapeLayer.lineWidth = 1
                layer?.addSublayer(shapeLayer)
            }
        }

        for flow in sankey.flows {
            guard let flowPoints = calculator.flowPoints[flow.id] else { continue }

            let fillColor = (flow.color.map { NSColor($0) } ?? NSColor.gray)
                .withAlphaComponent(settings.flowOpacity)
                .cgColor
            let path = flowPoints.path(using: NSBezierPath.self)
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = fillColor
            shapeLayer.lineWidth = 1
            layer?.addSublayer(shapeLayer)
        }
    }
}

#endif
