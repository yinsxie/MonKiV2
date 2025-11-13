//
//  TryView.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 13/11/25.
//

import SwiftUI

// MARK: - 1. Models
struct GroceryItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String // Using SF Symbols for this example
}

enum AppState {
    case browsing // Page 1
    case checkout // Page 2
}

// MARK: - 2. View Model
@Observable class SupermarketViewModel {
    // Inventory
    var shelfItems: [GroceryItem] = [
        GroceryItem(name: "Apple", icon: "apple.logo"),
        GroceryItem(name: "Carrot", icon: "carrot.fill"),
        GroceryItem(name: "Bread", icon: "birthday.cake.fill"),
        GroceryItem(name: "Milk", icon: "mug.fill"),
        GroceryItem(name: "Fish", icon: "fish.fill")
    ]
    
    var cartItems: [GroceryItem] = []
    var checkoutItems: [GroceryItem] = []
    
    // Dragging State
    var draggedItem: GroceryItem?
    var dragLocation: CGPoint = .zero
    
    // Drop Zone Frames (In Global Coordinate Space)
    var cartFrame: CGRect = .zero
    var checkoutFrame: CGRect = .zero
    
    // Current Page (for logic gating)
    var currentPageIndex: Int = 0
    
    // MARK: - Logic
    
    // Called when dragging ends
    func handleDrop() {
        guard let item = draggedItem else { return }
        
        // Logic: If on Page 1 (Index 0), we can drop into Cart
        if currentPageIndex == 0 {
            if cartFrame.contains(dragLocation) {
                moveToCart(item)
            }
        }
        
        // Logic: If on Page 2 (Index 1), we can drop from Cart to Checkout
        if currentPageIndex == 1 {
            // Note: In Page 2, we only drag FROM cart, so we check if we dropped ON checkout
            if checkoutFrame.contains(dragLocation) {
                checkout(item)
            }
        }
        
        // Reset
        draggedItem = nil
    }
    
    func moveToCart(_ item: GroceryItem) {
        // Remove from shelf, add to cart
        if let index = shelfItems.firstIndex(where: { $0.id == item.id }) {
            shelfItems.remove(at: index)
            cartItems.append(item)
        }
    }
    
    func checkout(_ item: GroceryItem) {
        // Remove from cart, add to checkout
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            cartItems.remove(at: index)
            checkoutItems.append(item)
        }
    }
    
    // Helper to return item to source if drop failed
    // (In this simple version, we just nil out draggedItem and SwiftUI redraws original)
}
