//
//  SankeySettings.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

import SwiftUI

public struct SankeySettings: Codable {
    public var axis: SankeyAxis = .horizontal

    public var insets: SankeyInsets = .zero

    /// Thickness of node in pt. Can be width or height, depending on `axix`
    public var nodeThickness: Double = 30

    /// Scale of node in %, affects height or width, depending on `axis`
    public var nodeScale: Double = 1

    /// Node spacing in %
    public var nodeSpacing: Double = 0

    public var nodeColors: [String] = ["#777777"]

    public var flowOpacity: Double = 0.45

    public var flowCurviness: Double = 0.5

    public var nodeCornerRadius: SankeyCornerRadius = .init(topLeft: 0, topRight: 0, bottomRight: 0, bottomLeft: 0)

    public var flowInsets: SankeyInsets = .zero
}
