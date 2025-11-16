//
//  MoneyHeader.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 14/11/25.
//

import SwiftUI
import Combine

final class MoneyHeader: ObservableObject {
    @Published var money: Money
    @Published var quantity: Int
    @Published var originalOwner: Player
    
    init(money: Money, quantity: Int, originalOwner: Player) {
        self.money = money
        self.quantity = quantity
        self.originalOwner = originalOwner
    }
}
