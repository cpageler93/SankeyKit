//
//  CGRect+NSEdgeInsets.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

#if os(macOS)

import AppKit

extension CGRect {
    func inset(by insets: NSEdgeInsets) -> CGRect {
        .init(
            x: origin.x + insets.left,
            y: origin.y + insets.top,
            width: width - (insets.left + insets.right),
            height: height - (insets.top + insets.bottom)
        )
    }
}

#endif
