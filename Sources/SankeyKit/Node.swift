//
//  Node.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 22.02.25.
//

import Foundation
import SwiftUI

public struct Node: Identifiable, Equatable, Hashable {
    public var id: UUID
    public var title: String
    public var color: Color?
}
