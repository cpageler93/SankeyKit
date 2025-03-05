//
//  CGRectPositionsTests.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

import Testing
import CoreGraphics
@testable import SankeyKit

@Test func positions() {
    let rect = CGRect(x: 10, y: 20, width: 30, height: 40)
    #expect(rect.topLeft == .init(x: 10, y: 20))
    #expect(rect.topRight == .init(x: 40, y: 20))
    #expect(rect.bottomRight == .init(x: 40, y: 60))
    #expect(rect.bottomLeft == .init(x: 10, y: 60))
}
