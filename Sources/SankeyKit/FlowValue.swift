//
//  FlowValue.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 22.02.25.
//

public enum FlowValue: Equatable {
    case double(Double)
    case unusedRemainderFromSource
    case unsourcedAmoutFromTarget

    init(stringValue: String) throws(FlowValueError) {
        switch stringValue {
        case "*":
            self = .unusedRemainderFromSource
        case "?":
            self = .unsourcedAmoutFromTarget
        default:
            let decimalString = stringValue.replacingOccurrences(of: ",", with: ".")
            guard let double = Double(decimalString) else {
                throw .init(message: "Unable to initialize FlowValue from \(stringValue)")
            }
            self = .double(double)
        }
    }
}

struct FlowValueError: Error {
    var message: String
}
