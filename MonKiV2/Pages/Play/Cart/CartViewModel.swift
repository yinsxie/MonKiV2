//
//  CartViewModel.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//
import SwiftUI

@Observable class CartViewModel {
    var items: [Item] = []
    
    func addItem(_ item: Item) {
        items.append(item)
        print("Item added to cart: \(item.name)")
    }
    
    func removeItem(withId id: UUID) {
        items.removeAll { $0.id == id }
        print("Item removed from cart with id: \(id)")
    }
}
