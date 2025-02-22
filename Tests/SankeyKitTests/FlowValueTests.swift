//
//  FlowValueTests.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 22.02.25.
//

import Testing
@testable import SankeyKit

@Test func initFromString() async throws {
    #expect(try FlowValue(stringValue: "*") == .unusedRemainderFromSource)
    #expect(try FlowValue(stringValue: "?") == .unsourcedAmoutFromTarget)
    #expect(try FlowValue(stringValue: "1") == .double(1))
    #expect(try FlowValue(stringValue: "1.5") == .double(1.5))
    #expect(try FlowValue(stringValue: "1,5") == .double(1.5))
    #expect(throws: FlowValueError.self) {
        try FlowValue(stringValue: "Ten")
    }
}
