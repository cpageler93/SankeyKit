//
//  NSEdgeInsets+SankeyInsets.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

#if os(macOS)

import Foundation

extension NSEdgeInsets {
    init(sankeyInsets: SankeyInsets) {
        self.init(
            top: sankeyInsets.top,
            left: sankeyInsets.leading,
            bottom: sankeyInsets.bottom,
            right: sankeyInsets.trailing
        )
    }
}

#endif
