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

        sankey.addFlow(from: a, value: 1, to: b)
        sankey.addFlow(from: a, value: 1, to: c)

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

    #expect(sankey.isStartingNode(nodeID: sankey.nodeID(title: "A")!) == true)
    #expect(sankey.isStartingNode(nodeID: sankey.nodeID(title: "B")!) == false)
    #expect(sankey.isStartingNode(nodeID: sankey.nodeID(title: "C")!) == false)
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

    sankey.addFlow(from: a, value: 2, to: b)
    sankey.addFlow(from: a, value: .unsourcedAmoutFromTarget, to: c)

    sankey.addFlow(from: b, value: 1, to: x)
    sankey.addFlow(from: b, value: .unusedRemainderFromSource, to: y)

    sankey.addFlow(from: c, value: 2, to: foo)
    sankey.addFlow(from: c, value: 2, to: bar)

    sankey.addFlow(from: foo, value: 1, to: fooOne)

    sankey.addFlow(from: bar, value: 1, to: bar1)
    sankey.addFlow(from: bar, value: .unusedRemainderFromSource, to: barStar)

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
@Test func valueForFlowWithFlowValueCalculation() {
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

    let flowAToB = sankey.addFlow(from: a, value: 2, to: b)
    let flowAToC = sankey.addFlow(from: a, value: .unsourcedAmoutFromTarget, to: c)

    let flowBToX = sankey.addFlow(from: b, value: 1, to: x)
    let flowBToY = sankey.addFlow(from: b, value: .unusedRemainderFromSource, to: y)

    let flowCToFoo = sankey.addFlow(from: c, value: 2, to: foo)
    let flowCToBar = sankey.addFlow(from: c, value: 2, to: bar)

    let flowFooToFooOne = sankey.addFlow(from: foo, value: 1, to: fooOne)

    let flowBarToBar1 = sankey.addFlow(from: bar, value: 1, to: bar1)
    let flowBarToBarStar = sankey.addFlow(from: bar, value: .unusedRemainderFromSource, to: barStar)

    #expect(sankey.valueForFlow(flow: flowAToB) == 2)
    #expect(sankey.valueForFlow(flow: flowAToC) == 4)
    #expect(sankey.valueForFlow(flow: flowBToX) == 1)
    #expect(sankey.valueForFlow(flow: flowBToY) == 1)
    #expect(sankey.valueForFlow(flow: flowCToFoo) == 2)
    #expect(sankey.valueForFlow(flow: flowCToBar) == 2)
    #expect(sankey.valueForFlow(flow: flowFooToFooOne) == 1)
    #expect(sankey.valueForFlow(flow: flowBarToBar1) == 1)
    #expect(sankey.valueForFlow(flow: flowBarToBarStar) == 1)
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

    sankey.addFlow(from: a, value: 2, to: one)
    sankey.addFlow(from: a, value: 2, to: two)
    sankey.addFlow(from: b, value: 2, to: one)
    sankey.addFlow(from: c, value: 2, to: two)

    #expect(sankey.valueForNode(id: sankey.nodeID(title: "A")!) == 4)
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "B")!) == 2)
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "C")!) == 2)
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "1")!) == 4)
    #expect(sankey.valueForNode(id: sankey.nodeID(title: "2")!) == 4)
}


//a [2] 1
//a [2] 2
//b [2] 1
//c [2] 2
//1 [1] x
//1 [3] y
//y [1] i
//y [1] j
//y [1] k
@Test func stages() {
    var sankey = Sankey()
    let a = sankey.addNodeIfNeeded(title: "A")
    let b = sankey.addNodeIfNeeded(title: "B")
    let c = sankey.addNodeIfNeeded(title: "C")
    let one = sankey.addNodeIfNeeded(title: "1")
    let two = sankey.addNodeIfNeeded(title: "2")
    let x = sankey.addNodeIfNeeded(title: "X")
    let y = sankey.addNodeIfNeeded(title: "Y")
    let i = sankey.addNodeIfNeeded(title: "I")
    let j = sankey.addNodeIfNeeded(title: "J")
    let k = sankey.addNodeIfNeeded(title: "K")

    sankey.addFlow(from: a, value: 2, to: one)
    sankey.addFlow(from: a, value: 2, to: two)
    sankey.addFlow(from: b, value: 2, to: one)
    sankey.addFlow(from: c, value: 2, to: two)
    sankey.addFlow(from: one, value: 1, to: x)
    sankey.addFlow(from: one, value: 3, to: y)
    sankey.addFlow(from: y, value: 1, to: i)
    sankey.addFlow(from: y, value: 1, to: j)
    sankey.addFlow(from: y, value: 1, to: k)

    let stages = sankey.stages
    #expect(stages.count == 4)
    #expect(stages[0].nodeIDs.count == 3)
    #expect(stages[0].nodeIDs[0] == a)
    #expect(stages[0].nodeIDs[1] == b)
    #expect(stages[0].nodeIDs[2] == c)

    #expect(stages[1].nodeIDs.count == 2)
    #expect(stages[1].nodeIDs[0] == one)
    #expect(stages[1].nodeIDs[1] == two)

    #expect(stages[2].nodeIDs.count == 2)
    #expect(stages[2].nodeIDs[0] == x)
    #expect(stages[2].nodeIDs[1] == y)

    #expect(stages[3].nodeIDs.count == 3)
    #expect(stages[3].nodeIDs[0] == i)
    #expect(stages[3].nodeIDs[1] == j)
    #expect(stages[3].nodeIDs[2] == k)
}

//a [2] 1
//a [2] 2
//b [2] 1
//c [2] 2
//1 [1] x
//1 [3] y
//y [1] i
//y [1] j
//y [1] k
@Test func sumOfValuesForStage() {
    var sankey = Sankey()
    let a = sankey.addNodeIfNeeded(title: "A")
    let b = sankey.addNodeIfNeeded(title: "B")
    let c = sankey.addNodeIfNeeded(title: "C")
    let one = sankey.addNodeIfNeeded(title: "1")
    let two = sankey.addNodeIfNeeded(title: "2")
    let x = sankey.addNodeIfNeeded(title: "X")
    let y = sankey.addNodeIfNeeded(title: "Y")
    let i = sankey.addNodeIfNeeded(title: "I")
    let j = sankey.addNodeIfNeeded(title: "J")
    let k = sankey.addNodeIfNeeded(title: "K")

    sankey.addFlow(from: a, value: 2, to: one)
    sankey.addFlow(from: a, value: 2, to: two)
    sankey.addFlow(from: b, value: 2, to: one)
    sankey.addFlow(from: c, value: 2, to: two)
    sankey.addFlow(from: one, value: 1, to: x)
    sankey.addFlow(from: one, value: 3, to: y)
    sankey.addFlow(from: y, value: 1, to: i)
    sankey.addFlow(from: y, value: 1, to: j)
    sankey.addFlow(from: y, value: 1, to: k)

    #expect(sankey.valueForStage(stage: sankey.stages[0]) == 8)
    #expect(sankey.valueForStage(stage: sankey.stages[1]) == 8)
    #expect(sankey.valueForStage(stage: sankey.stages[2]) == 4)
    #expect(sankey.valueForStage(stage: sankey.stages[3]) == 3)
}
