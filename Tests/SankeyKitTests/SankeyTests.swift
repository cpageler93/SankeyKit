//
//  SankeyTests.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 22.02.25.
//

import Testing
@testable import SankeyKit

extension Sankey {
    static var startSimple: Sankey {
        var sankey = Sankey()
        let a = sankey.addNodeIfNeeded(title: "A")
        let b = sankey.addNodeIfNeeded(title: "B")
        let c = sankey.addNodeIfNeeded(title: "C")

        sankey.addFlow(from: a, to: b, value: .double(1))
        sankey.addFlow(from: a, to: c, value: .double(1))

        return sankey
    }
}

@Test func addNodeIfNeeded() {
    var sankey = Sankey()
    #expect(sankey.nodes.count == 0)
    sankey.addNodeIfNeeded(title: "A")
    #expect(sankey.nodes.count == 1)
    sankey.addNodeIfNeeded(title: "A")
    #expect(sankey.nodes.count == 1)
    sankey.addNodeIfNeeded(title: "B")
    #expect(sankey.nodes.count == 2)
}

@Test func nodeID() {
    var sankey = Sankey()
    let a = sankey.addNodeIfNeeded(title: "A")
    #expect(sankey.node(id: a)?.title == "A")
    #expect(sankey.node(id: .init()) == nil)
}

@Test func startingNodes() {
    let sankey = Sankey.startSimple

    #expect(sankey.startingNodeIDs().count == 1)
    #expect(sankey.startingNodeIDs()[0] == sankey.nodeID(title: "A"))
}

@Test func flowsSourceNodeID() {
    let sankey = Sankey.startSimple

    let flows = sankey.flows(sourceNodeID: sankey.nodeID(title: "A")!)
    #expect(flows.count == 2)
    #expect(flows[0].target == sankey.nodeID(title: "B")!)
    #expect(flows[1].target == sankey.nodeID(title: "C")!)

    #expect(sankey.flows(sourceNodeID: sankey.nodeID(title: "B")!).count == 0)
    #expect(sankey.flows(sourceNodeID: sankey.nodeID(title: "C")!).count == 0)
}

@Test func flowsTargetNodeID() {
    let sankey = Sankey.startSimple

    let bFlows = sankey.flows(targetNodeID: sankey.nodeID(title: "B")!)
    #expect(bFlows.count == 1)
    #expect(bFlows[0].source == sankey.nodeID(title: "A")!)

    let cFlows = sankey.flows(targetNodeID: sankey.nodeID(title: "C")!)
    #expect(cFlows.count == 1)
    #expect(cFlows[0].source == sankey.nodeID(title: "A")!)

    #expect(sankey.flows(targetNodeID: sankey.nodeID(title: "A")!).count == 0)
}

@Test func valueForNode() {
    let sankey = Sankey.startSimple
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "A")!) == 2)
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "B")!) == 1)
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "C")!) == 1)
}

//a [2] b
//a [?] c
//
//b [1] x
//b [*] y
//
//c [2] foo
//c [2] bar
//
//foo [1] fooone
//
//bar [1] bar1
//bar [*] barstar
@Test func valueForNodeWithFlowValueCalculation() {
    var sankey = Sankey()
    let a = sankey.addNodeIfNeeded(title: "A")
    let b = sankey.addNodeIfNeeded(title: "B")
    let c = sankey.addNodeIfNeeded(title: "C")

    let x = sankey.addNodeIfNeeded(title: "X")
    let y = sankey.addNodeIfNeeded(title: "Y")

    let foo = sankey.addNodeIfNeeded(title: "foo")
    let bar = sankey.addNodeIfNeeded(title: "bar")

    let fooOne = sankey.addNodeIfNeeded(title: "fooOne")

    let bar1 = sankey.addNodeIfNeeded(title: "bar1")
    let barStar = sankey.addNodeIfNeeded(title: "barStar")

    sankey.addFlow(from: a, to: b, value: .double(2))
    sankey.addFlow(from: a, to: c, value: .unsourcedAmoutFromTarget)

    sankey.addFlow(from: b, to: x, value: .double(1))
    sankey.addFlow(from: b, to: y, value: .unusedRemainderFromSource)

    sankey.addFlow(from: c, to: foo, value: .double(2))
    sankey.addFlow(from: c, to: bar, value: .double(2))

    sankey.addFlow(from: foo, to: fooOne, value: .double(1))

    sankey.addFlow(from: bar, to: bar1, value: .double(1))
    sankey.addFlow(from: bar, to: barStar, value: .unusedRemainderFromSource)

    #expect(sankey.valueForNode(id: sankey.nodeID(title: "A")!) == 6)
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "B")!) == 2)
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "C")!) == 4)

    #expect(sankey.valueForNode(id: sankey.nodeID(title: "X")!) == 1)
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "Y")!) == 1)

    #expect(sankey.valueForNode(id: sankey.nodeID(title: "foo")!) == 2)
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "bar")!) == 2)

    #expect(sankey.valueForNode(id: sankey.nodeID(title: "fooOne")!) == 1)
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "bar1")!) == 1)
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "barStar")!) == 1)
}

//a [2] 1
//a [2] 2
//b [2] 1
//c [2] 2
@Test func valueForNodeWithIntersection() {
    var sankey = Sankey()
    let a = sankey.addNodeIfNeeded(title: "A")
    let b = sankey.addNodeIfNeeded(title: "B")
    let c = sankey.addNodeIfNeeded(title: "C")
    let one = sankey.addNodeIfNeeded(title: "1")
    let two = sankey.addNodeIfNeeded(title: "2")

    sankey.addFlow(from: a, to: one, value: .double(2))
    sankey.addFlow(from: a, to: two, value: .double(2))
    sankey.addFlow(from: b, to: one, value: .double(2))
    sankey.addFlow(from: c, to: two, value: .double(2))

    #expect(sankey.valueForNode(id: sankey.nodeID(title: "A")!) == 4)
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "B")!) == 2)
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "C")!) == 2)
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "1")!) == 4)
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "2")!) == 4)
}
