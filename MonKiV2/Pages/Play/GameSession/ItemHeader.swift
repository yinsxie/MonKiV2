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
