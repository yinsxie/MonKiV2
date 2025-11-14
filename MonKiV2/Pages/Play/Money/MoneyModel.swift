//
//  MoneyModel.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 14/11/25.
//

import SwiftUI

struct Money: Identifiable, Equatable {
    let id: UUID
    let price: Int
    let color: Color
    let imageAssetPath: String?
    
    // MARK: - Kustom Initializer

    init(price: Int) {
        self.id = UUID()
        self.price = price
        self.color = Money.getStaticColor(for: price)
        self.imageAssetPath = ""
    }
    
    // MARK: - Mock & Data Statis
    static let mockMoney = Money(price: 10)
    
    static let money: [Money] = [

    ]
    
    static func == (lhs: Money, rhs: Money) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Private Helper
    private static func getStaticColor(for price: Int) -> Color {
        // MARK: - Adjust later based on nominals
        switch price {
        case 100:
            return ColorPalette.pink900
        default:
            return ColorPalette.neutral500
        }
    }
}
