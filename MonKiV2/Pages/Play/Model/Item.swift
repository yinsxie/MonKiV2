//
//  Item.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

struct Item: Identifiable {
    let id: UUID
    let name: String
    let price: Int
    let aisle: String?
    let imageAssetPath: String
    
    static let mockItem = Item(id: UUID(), name: "Test item", price: 10, aisle: nil, imageAssetPath: "")
    
    //TODO: Fill in the items here (filled based on figma, adjust later)
    static let items: [Item] = [
        // Staples
        Item(id: UUID(), name: "Rice", price: 5, aisle: nil, imageAssetPath: ""),
        Item(id: UUID(), name: "Noodles", price: 5, aisle: nil, imageAssetPath: ""),
        Item(id: UUID(), name: "Bread", price: 5, aisle: nil, imageAssetPath: ""),
        
        // Vegetables
        Item(id: UUID(), name: "Carrot", price: 3, aisle: nil, imageAssetPath: ""),
        Item(id: UUID(), name: "Tomato", price: 3, aisle: nil, imageAssetPath: ""),
        Item(id: UUID(), name: "Broccoli", price: 4, aisle: nil, imageAssetPath: ""),
        Item(id: UUID(), name: "Corn", price: 3, aisle: nil, imageAssetPath: ""),
        Item(id: UUID(), name: "Potato", price: 3, aisle: nil, imageAssetPath: ""),
        
        // Processed
        Item(id: UUID(), name: "Cheese", price: 8, aisle: nil, imageAssetPath: ""),
        Item(id: UUID(), name: "Milk", price: 7, aisle: nil, imageAssetPath: ""),
        Item(id: UUID(), name: "Sausage", price: 7, aisle: nil, imageAssetPath: ""),
        
        // Daily Protein
        Item(id: UUID(), name: "Chicken", price: 12, aisle: nil, imageAssetPath: ""),
        Item(id: UUID(), name: "Fish", price: 15, aisle: nil, imageAssetPath: ""),
        Item(id: UUID(), name: "Egg", price: 5, aisle: nil, imageAssetPath: ""),
        
        // Premium Protein
        Item(id: UUID(), name: "Beef", price: 18, aisle: nil, imageAssetPath: ""),
        Item(id: UUID(), name: "Shrimp", price: 20, aisle: nil, imageAssetPath: "")
    ]
}
