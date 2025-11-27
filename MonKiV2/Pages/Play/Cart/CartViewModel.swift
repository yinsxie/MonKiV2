//
//  CartViewModel.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//
import SwiftUI

@Observable class CartViewModel {
    
    weak var parent: PlayViewModel?
    
    var shakeTrigger: Int = 0

    init(parent: PlayViewModel?) {
        self.parent = parent
    }
    
    var items: [CartItem] = []
    var totalPrice: Int { items.reduce(0) { $0 + $1.item.price } }
    private let maxCapacity = 12
    var isFull: Bool {
        items.count >= maxCapacity
    }
    
    func triggerShake() {
        shakeTrigger += 1
    }
  
    func addNewItem(_ item: Item) {      
        let newCartItem = CartItem(item: item)
        items.append(newCartItem)
        print("Item added to cart: \(item.name) (Instance ID: \(newCartItem.id))")
    }
    
    func addExistingItem(_ cartItem: CartItem) {
        items.append(cartItem)
        print("EXISTING Item added to cart: \(cartItem.item.name) (Instance ID: \(cartItem.id))")
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
