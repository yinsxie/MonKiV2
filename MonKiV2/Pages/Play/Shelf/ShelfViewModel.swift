//
//  ShelfViewModel.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//
import SwiftUI

// TODO: Change with Common data model implementation
struct GroceryItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let price: Double
    let icon: String
}

@Observable class ShelfViewModel {
    var items: [GroceryItem] = [
        GroceryItem(name: "Carrot", price: 1000, icon: "carrot.fill"),
        GroceryItem(name: "Apple", price: 2000, icon: "apple.logo")
    ]
    
    func removeItem(withId itemID: UUID) {
        items.removeAll { $0.id == itemID }
    }
}
