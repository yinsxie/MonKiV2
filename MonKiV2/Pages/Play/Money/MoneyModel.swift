//
//  MoneyModel.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 14/11/25.
//

import SwiftUI

struct Money: Identifiable, Equatable {
    let id: UUID
    let currency: Currency
    
    // MARK: - Custom Initializer
    init(forCurrency currency: Currency) {
        self.id = UUID()
        self.currency = currency
    }
    
    // MARK: - Mock & Data Statis
    static let mockMoney = Money(forCurrency: .idr10)
    
    static let money: [Money] = [

    ]
    
    static func == (lhs: Money, rhs: Money) -> Bool {
        lhs.id == rhs.id
    }
}
