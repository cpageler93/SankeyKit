//
//  SankeySettings.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

import SwiftUI

public struct SankeySettings: Codable {
    public var axis: SankeyAxis = .horizontal

    public var insets: SankeyInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    public var nodeWidth: Double = 30

    /// Node height in %
    public var nodeHeight: Double = 1

    /// Node spacing in %
    public var nodeSpacing: Double = 0

    public var nodeColors: [String] = ["#777777"]

    public var flowOpacity: Double = 0.45

    public var flowCurviness: Double = 0.5
}
