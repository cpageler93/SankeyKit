//
//  ColorSankeyHexTests.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

import Testing
import SwiftUI
@testable import SankeyKit

@Test func rgb3() {
    #expect(Color(sankeyHex: "#FFF")?.hexString == "#FFFFFF")
}

@Test func rgb6() {
    #expect(Color(sankeyHex: "#FFFFFF")?.hexString == "#FFFFFF")
}

@Test func rgb3WithOpacity() {
    #expect(Color(sankeyHex: "#FFF.0")?.hexString == "#FFFFFF00")
    #expect(Color(sankeyHex: "#FFF.1")?.hexString == "#FFFFFF19")
    #expect(Color(sankeyHex: "#FFF.2")?.hexString == "#FFFFFF33")
    #expect(Color(sankeyHex: "#FFF.3")?.hexString == "#FFFFFF4C")
    #expect(Color(sankeyHex: "#FFF.4")?.hexString == "#FFFFFF66")
    #expect(Color(sankeyHex: "#FFF.5")?.hexString == "#FFFFFF7F")
    #expect(Color(sankeyHex: "#FFF.6")?.hexString == "#FFFFFF99")
    #expect(Color(sankeyHex: "#FFF.7")?.hexString == "#FFFFFFB3")
    #expect(Color(sankeyHex: "#FFF.8")?.hexString == "#FFFFFFCC")
    #expect(Color(sankeyHex: "#FFF.9")?.hexString == "#FFFFFFE6")
}

@Test func rgb6WithOpacity() {
    #expect(Color(sankeyHex: "#FFFFFF.0")?.hexString == "#FFFFFF00")
    #expect(Color(sankeyHex: "#FFFFFF.1")?.hexString == "#FFFFFF19")
    #expect(Color(sankeyHex: "#FFFFFF.2")?.hexString == "#FFFFFF33")
    #expect(Color(sankeyHex: "#FFFFFF.3")?.hexString == "#FFFFFF4C")
    #expect(Color(sankeyHex: "#FFFFFF.4")?.hexString == "#FFFFFF66")
    #expect(Color(sankeyHex: "#FFFFFF.5")?.hexString == "#FFFFFF7F")
    #expect(Color(sankeyHex: "#FFFFFF.6")?.hexString == "#FFFFFF99")
    #expect(Color(sankeyHex: "#FFFFFF.7")?.hexString == "#FFFFFFB3")
    #expect(Color(sankeyHex: "#FFFFFF.8")?.hexString == "#FFFFFFCC")
    #expect(Color(sankeyHex: "#FFFFFF.9")?.hexString == "#FFFFFFE6")
}
