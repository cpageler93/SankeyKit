//
//  Typealias.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 12.03.25.
//

#if canImport(UIKit)
import UIKit
typealias NativeBezierPath = UIBezierPath
typealias NativeColor = UIColor
#else
import AppKit
typealias NativeBezierPath = NSBezierPath
typealias NativeColor = NSColor
#endif
