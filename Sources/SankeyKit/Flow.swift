//
//  Flow.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 22.02.25.
//

import Foundation
import SwiftUI

public struct Flow: Equatable, Hashable, Identifiable {
    public var id: UUID
    public var source: Node.ID
    public var target: Node.ID
    public var value: FlowValue
    public var color: Color?
}
