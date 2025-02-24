//
//  SankeyMaticStringTests.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 22.02.25.
//

import Testing
@testable import SankeyKit

@Test func financialResults() async throws {
    let string = """
    // Sample Financial Results diagram:

    DivisionA [900] Revenue
    DivisionB [750] Revenue
    DivisionC [150] Revenue

    Revenue [800] Cost of Sales
    Revenue [1000] Gross Profit

    Gross Profit [10] Amortization
    Gross Profit [640] Selling, General & Administration
    Gross Profit [350] Operating Profit

    Operating Profit [90] Tax
    Operating Profit [260] Net Profit

    // Profit - blue
    :Gross Profit #48e <<
    :Operating Profit #48e <<
    :Net Profit #48e <<

    // Expenses - rust
    :Tax #d97 <<
    :Selling, General & Administration #d97 <<
    :Amortization #d97 <<

    // Cost - gray
    :Cost of Sales #bbb <<

    // main Revenue node: dark grey
    :Revenue #555
    """ as SankeyMaticString

    let sankey = try string.initSankey()

    #expect(sankey.nodes.count == 11)
    #expect(sankey.nodes.contains(where: { $0.title == "DivisionA" }))
    #expect(sankey.nodes.contains(where: { $0.title == "DivisionA" }))
    #expect(sankey.nodes.contains(where: { $0.title == "DivisionA" }))
    #expect(sankey.nodes.contains(where: { $0.title == "Revenue" }))
    #expect(sankey.nodes.contains(where: { $0.title == "Cost of Sales" }))
    #expect(sankey.nodes.contains(where: { $0.title == "Gross Profit" }))
    #expect(sankey.nodes.contains(where: { $0.title == "Amortization" }))
    #expect(sankey.nodes.contains(where: { $0.title == "Selling, General & Administration" }))
    #expect(sankey.nodes.contains(where: { $0.title == "Operating Profit" }))
    #expect(sankey.nodes.contains(where: { $0.title == "Tax" }))
    #expect(sankey.nodes.contains(where: { $0.title == "Net Profit" }))

    #expect(sankey.flows.count == 10)

    // DivisionA [900] Revenue
    #expect(sankey.node(id: sankey.flows[0].source)?.title == "DivisionA")
    #expect(sankey.flows[0].value == 900)
    #expect(sankey.node(id: sankey.flows[0].target)?.title == "Revenue")

    // DivisionB [750] Revenue
    #expect(sankey.node(id: sankey.flows[1].source)?.title == "DivisionB")
    #expect(sankey.flows[1].value == 750)
    #expect(sankey.node(id: sankey.flows[1].target)?.title == "Revenue")

    // DivisionC [150] Revenue
    #expect(sankey.node(id: sankey.flows[2].source)?.title == "DivisionC")
    #expect(sankey.flows[2].value == 150)
    #expect(sankey.node(id: sankey.flows[2].target)?.title == "Revenue")

    // Revenue [800] Cost of Sales
    #expect(sankey.node(id: sankey.flows[3].source)?.title == "Revenue")
    #expect(sankey.flows[3].value == 800)
    #expect(sankey.node(id: sankey.flows[3].target)?.title == "Cost of Sales")

    // Revenue [1000] Gross Profit
    #expect(sankey.node(id: sankey.flows[4].source)?.title == "Revenue")
    #expect(sankey.flows[4].value == 1000)
    #expect(sankey.node(id: sankey.flows[4].target)?.title == "Gross Profit")

    // Gross Profit [10] Amortization
    #expect(sankey.node(id: sankey.flows[5].source)?.title == "Gross Profit")
    #expect(sankey.flows[5].value == 10)
    #expect(sankey.node(id: sankey.flows[5].target)?.title == "Amortization")

    // Gross Profit [640] Selling, General & Administration
    #expect(sankey.node(id: sankey.flows[6].source)?.title == "Gross Profit")
    #expect(sankey.flows[6].value == 640)
    #expect(sankey.node(id: sankey.flows[6].target)?.title == "Selling, General & Administration")

    // Gross Profit [350] Operating Profit
    #expect(sankey.node(id: sankey.flows[7].source)?.title == "Gross Profit")
    #expect(sankey.flows[7].value == 350)
    #expect(sankey.node(id: sankey.flows[7].target)?.title == "Operating Profit")

    // Operating Profit [90] Tax
    #expect(sankey.node(id: sankey.flows[8].source)?.title == "Operating Profit")
    #expect(sankey.flows[8].value == 90)
    #expect(sankey.node(id: sankey.flows[8].target)?.title == "Tax")

    // Operating Profit [260] Net Profit
    #expect(sankey.node(id: sankey.flows[9].source)?.title == "Operating Profit")
    #expect(sankey.flows[9].value == 260)
    #expect(sankey.node(id: sankey.flows[9].target)?.title == "Net Profit")
}

@Test func floatingValue() async throws {
    let string = """
    A [100] B
    A [50.5] C
    A [70,1] D
    """ as SankeyMaticString

    let sankey = try string.initSankey()

    #expect(sankey.nodes.count == 4)
    #expect(sankey.nodes.contains(where: { $0.title == "A" }))
    #expect(sankey.nodes.contains(where: { $0.title == "B" }))
    #expect(sankey.nodes.contains(where: { $0.title == "C" }))
    #expect(sankey.nodes.contains(where: { $0.title == "D" }))

    #expect(sankey.flows.count == 3)
    #expect(sankey.flows[0].source == sankey.nodes[0].id)
    #expect(sankey.flows[0].target == sankey.nodes[1].id)
    #expect(sankey.flows[0].value == 100)
    #expect(sankey.flows[1].source == sankey.nodes[0].id)
    #expect(sankey.flows[1].target == sankey.nodes[2].id)
    #expect(sankey.flows[1].value == 50.5)
    #expect(sankey.flows[2].source == sankey.nodes[0].id)
    #expect(sankey.flows[2].target == sankey.nodes[3].id)
    #expect(sankey.flows[2].value == 70.1)
}
