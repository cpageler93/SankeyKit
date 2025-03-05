//
//  UIEdgeInsets+SankeyInsets.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

#if canImport(UIKit)

import UIKit

extension UIEdgeInsets {
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
