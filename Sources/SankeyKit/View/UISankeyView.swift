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

                let nodeLayer = NodeLayer(
                    node: node,
                    rect: nodeRect,
                    index: nodeIndex,
                    settings: settings
                )
                layer.addSublayer(nodeLayer)
            }
        }

        for flow in sankey.flows {
            guard let flowPoints = calculator.flowPoints[flow.id] else { continue }
            let flowLayer = FlowLayer(
                flow: flow,
                flowPoints: flowPoints,
                settings: settings
            )
            layer.addSublayer(flowLayer)
        }
    }
}

#endif
