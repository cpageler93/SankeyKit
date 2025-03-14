//
//  Color+Hex.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

import SwiftUI

extension Color {
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        let multiplier = CGFloat(255.999999)

        NativeColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        } else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
}

extension Color {
    init?(sankeyHex hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var alpha: Double = 1.0

        // Check if string contains opacity "#660066.5"
        if let range = hexString.range(of: #"\.\d+"#, options: .regularExpression) {
            let alphaString = "0\(hexString[range])"
            if let alphaValue = Double(alphaString) {
                alpha = alphaValue
            }
            hexString.removeSubrange(range) // Entferne die Alpha-Angabe aus dem HEX-String
        }

        let hexCount = hexString.count

        var rgb: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&rgb) else { return nil }

        let r, g, b: UInt64
        switch hexCount {
        case 3:
            (r, g, b) = ((rgb >> 8) * 17, (rgb >> 4 & 0xF) * 17, (rgb & 0xF) * 17)
        case 6:
            (r, g, b) = (rgb >> 16, rgb >> 8 & 0xFF, rgb & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: alpha
        )
    }

    init?(hex: String) {
        let hex = hex
            .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            .replacingOccurrences(of: "#", with: "")

        var int: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&int) else { return nil }

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
