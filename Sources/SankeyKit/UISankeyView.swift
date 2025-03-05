//
//  UISankeyView.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

#if canImport(UIKit)

import SwiftUI
import UIKit

public class UISankeyView: UIView {
    public var sankey: Sankey {
        didSet { setNeedsLayout() }
    }
    public var settings: SankeySettings {
        didSet { setNeedsLayout() }
    }

    public init(sankey: Sankey, settings: SankeySettings) {
        self.sankey = sankey
        self.settings = settings

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let calculator = SankeyCalculator(sankey: sankey, settings: settings, rect: bounds)

        // Clear everything
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        for stage in sankey.stages {
            for nodeID in stage.nodeIDs {
                guard let node = sankey.node(id: nodeID) else { continue }
                guard let nodeIndex = sankey.nodes.firstIndex(of: node) else { continue }
                guard let nodeRect = calculator.nodeRects[nodeID] else { continue }

                let nodeFillColor = node.color.map { UIColor($0) }
                let settingsColor = Color(hex: settings.nodeColors[nodeIndex % settings.nodeColors.count])
                    .map { UIColor($0) }
                let defaultColor = UIColor.gray
                let fillColor = nodeFillColor ?? settingsColor ?? defaultColor

                let path = UIBezierPath(rect: nodeRect)
                let shapeLayer = CAShapeLayer()
                shapeLayer.path = path.cgPath
                shapeLayer.fillColor = fillColor.cgColor
                shapeLayer.lineWidth = 1
                layer.addSublayer(shapeLayer)
            }
        }

        for flow in sankey.flows {
            guard let flowPoints = calculator.flowPoints[flow.id] else { continue }

            let fillColor = (flow.color.map { UIColor($0) } ?? UIColor.gray)
                .withAlphaComponent(settings.flowOpacity)
                .cgColor
            let path = flowPoints.path(using: UIBezierPath.self)
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = fillColor
            shapeLayer.lineWidth = 1
            layer.addSublayer(shapeLayer)
        }
    }
}

#endif
