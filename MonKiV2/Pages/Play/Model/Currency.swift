//
//  currency.swift
//  MonKiV2
//
//  Created by William on 17/11/25.
//
import SwiftUI

enum Currency: String, Codable, CaseIterable {
    case idr100
    case idr50
    case idr20
    case idr10
    case idr5
    case idr2
    case idr1
    
    var value: Int {
        switch self {
        case .idr100:
            return 100
        case .idr50:
            return 50
        case .idr20:
            return 20
        case .idr10:
            return 10
        case .idr5:
            return 5
        case .idr2:
            return 2
        case .idr1:
            return 1
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .idr100:
            return ColorPalette.money100Foreground
        case .idr50:
            return ColorPalette.money50Foreground
        case .idr20:
            return ColorPalette.money20Foreground
        case .idr10:
            return ColorPalette.money10Foreground
        case .idr5:
            return ColorPalette.money5Foreground
        case .idr2:
            return ColorPalette.money2Foreground
        case .idr1:
            return ColorPalette.money1Foreground
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .idr100:
            return ColorPalette.money100Background
        case .idr50:
            return ColorPalette.money50Background
        case .idr20:
            return ColorPalette.money20Background
        case .idr10:
            return ColorPalette.money10Background
        case .idr5:
            return ColorPalette.money5Background
        case .idr2:
            return ColorPalette.money2Background
        case .idr1:
            return ColorPalette.money1Background
        }
    }
    
    var imageAssetPath: String {
        switch self {
        case .idr100:
            return "idr100"
        case .idr50:
            return "idr50"
        case .idr20:
            return "idr20"
        case .idr10:
            return "idr10"
        case .idr5:
            return "idr5"
        case .idr2:
            return "idr2"
        case .idr1:
            return "idr1"
        }
    }
    
    init(value: Int) {
        switch value {
        case 100:
            self = .idr100
        case 50:
            self = .idr50
        case 20:
            self = .idr20
        case 10:
            self = .idr10
        case 5:
            self = .idr5
        case 2:
            self = .idr2
        case 1:
            self = .idr1
        default:
            self = .idr1
        }
    }
}

extension Currency {
    // Break down a given amount into the least number of currency denominations
    static func breakdown(from amount: Int) -> [Currency] {
        // Return empty if the input is not a positive integer
        guard amount > 0 else { return [] }

        var remaining = amount
        var result: [Currency] = []

        // Sorted currencies from largest to smallest
        let denominations: [Currency] = [.idr100, .idr50, .idr20, .idr10, .idr5, .idr2, .idr1]

        for currency in denominations {
            while remaining >= currency.value {
                result.append(currency)
                remaining -= currency.value
            }
        }

        return result
    }
}
