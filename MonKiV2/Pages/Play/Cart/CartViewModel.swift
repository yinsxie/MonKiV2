//
//  CartViewModel.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//
import SwiftUI

@Observable class CartViewModel {
    var items: [GroceryItem] = []
    
    func addItem(_ item: GroceryItem) {
        items.append(item)
    }
    
    func removeItem(withId id: UUID) {
        items.removeAll { $0.id == id }
    }
}
