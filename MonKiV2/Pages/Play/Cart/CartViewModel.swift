//
//  CartViewModel.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//
import SwiftUI

@Observable class CartViewModel {
    
    weak var parent: PlayViewModel?

    init(parent: PlayViewModel?) {
        self.parent = parent
    }
    
    var items: [CartItem] = []
    
    func addItem(_ item: Item) {
        let newCartItem = CartItem(item: item)
        items.append(newCartItem)
        print("Item added to cart: \(item.name) (Instance ID: \(newCartItem.id))")
    }
    
    func removeItem(withId id: UUID) {
        items.removeAll { $0.id == id }
        print("Item removed from cart with instance id: \(id)")
    }
    
    func popItem(withId id: UUID) -> CartItem? {
        let item = items.first { $0.id == id }
        items.removeAll { $0.id == id }
        return item
    }
    
    func containsItem(withId id: UUID) -> Bool {
        return items.contains { $0.id == id }
    }
}
