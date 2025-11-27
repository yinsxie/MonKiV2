//
//  ItemHeader.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI
import Combine

final class ItemHeader: ObservableObject {
    @Published var item: Item
    @Published var quantity: Int
    @Published var originalOwner: Player
    
    init(item: Item, quantity: Int, originalOwner: Player) {
        self.item = item
        self.quantity = quantity
        self.originalOwner = originalOwner
    }
}
    
typealias PurchasedItem = ItemHeader
typealias CheckoutItem = ItemHeader

// MARK: - Helper Extensions
extension ItemHeader {
//    Untuk memformat SATU item jadi string.
//    Contoh: "5 Egg"
    var formatted: String {
        return "\(quantity) \(item.name)"
    }
}

extension Array where Element == ItemHeader {
//    Untuk memformat ARRAY dari ChekoutItem jadi satu string.
//    Contoh: "5 Egg, 2 Tomato"
    func formattedAllIngredientsToString() -> String {
        return self.map { $0.formatted }.joined(separator: ", ")
    }
}
