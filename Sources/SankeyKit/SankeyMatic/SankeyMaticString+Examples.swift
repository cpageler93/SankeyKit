//
//  SankeyMaticString+Examples.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

extension SankeyMaticString {
    enum Example {
        static var startSimple: Sankey {
            try! ("""
            a [1] b
            a [1] c
            """ as SankeyMaticString).initSankey()
        }

        static var financialResults: Sankey {
            try! ("""
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
            """ as SankeyMaticString).initSankey()
        }

        static var jobSearch: Sankey {
            try! ("""
            // Sample Job Search diagram:

            Applications [4] 1st Interviews
            Applications [9] Rejected
            Applications [4] No Answer

            1st Interviews [2] 2nd Interviews
            1st Interviews [2] No Offer

            2nd Interviews [2] Offers

            Offers [1] Accepted
            Offers [1] Declined
            """ as SankeyMaticString).initSankey()
        }

        static var journey: Sankey {
            try! ("""
            // List each player's moves all at once
            // Use one color for each player
            // Use an amount of 1 for each move
            // Check "Using the exact input order" below

            // Experiment with reordering players!

            :Player 1: #76a
            Player 1: [1] 1A #76a
            1A [1] 2C #76a
            2C [1] 3E #76a
            3E [1] Player 1 #76a
            :Player 1 #76a

            :Player 2: #e37
            Player 2: [1] 1B #e37
            1B [1] 2D #e37
            2D [1] 3E #e37
            3E [1] Player 2 #e37
            :Player 2 #e37

            :Player 3: #bb2
            Player 3: [1] 1A #bb2
            1A [1] 2D #bb2
            2D [1] 3E #bb2
            3E [1] Player 3 #bb2
            :Player 3 #bb2
            """ as SankeyMaticString).initSankey()
        }

        static var rankedElection: Sankey {
            try! ("""
            // Sample Ranked Election diagram

            GH Round 1 [300000] GH Round 2
            EF Round 1 [220000] EF Round 2
            CD Round 1 [200000] CD Round 2
            AB Round 1 [10000] GH Round 2
            AB Round 1 [25000] EF Round 2
            AB Round 1 [20000] CD Round 2

            GH Round 2 [310000] GH Round 3 Projected Winner
            EF Round 2 [245000] EF Round 3
            CD Round 2 [50000] GH Round 3 Projected Winner
            CD Round 2 [95000] EF Round 3

            // This line sets a custom gray color:
            :No further votes #555 <<
            CD Round 2 [75000] No further votes
            AB Round 1 [20000] No further votes
            """ as SankeyMaticString).initSankey()
        }

        static var budget: Sankey {
            try! ("""
            // Enter Flows between Nodes, like this:
            //         Source [AMOUNT] Target

            Wages [1500] Budget
            Other [250] Budget

            Budget [450] Taxes
            Budget [420] Housing
            Budget [400] Food
            Budget [255] Transportation

            // You can set a Node's color, like this:
            :Budget #057
            //            ...or a color for a single Flow:
            Budget [160] Other Necessities #606

            // "[*]" means "Use any amount left over":
            Budget [*] Savings

            // Use the controls below to customize
            // your diagram's appearance...
            """ as SankeyMaticString).initSankey()
        }
    }
}
