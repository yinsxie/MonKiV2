//
//  Item.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

struct Item: Identifiable, Equatable {
    let id: UUID
    let name: String
    let price: Int
    let aisle: String?
    let imageAssetPath: String
    
    static let mockItem = Item(id: UUID(), name: "Carrot", price: 3, aisle: "Sayur", imageAssetPath: "wortel")
    
    // TODO: Add strings of actual asset + aisle adjustment
    static let items: [Item] = [
        // Pokok
        Item(id: UUID(), name: "Rice", price: 6, aisle: "Pokok", imageAssetPath: "nasi"),
        Item(id: UUID(), name: "Pasta", price: 6, aisle: "Pokok", imageAssetPath: "mie"),
        Item(id: UUID(), name: "Bread", price: 7, aisle: "Pokok", imageAssetPath: "roti"),
        
        // Sayur
        Item(id: UUID(), name: "Carrot", price: 6, aisle: "Sayur", imageAssetPath: "wortel"),
        Item(id: UUID(), name: "Tomato", price: 6, aisle: "Sayur", imageAssetPath: "tomat"),
        Item(id: UUID(), name: "Broccoli", price: 8, aisle: "Sayur", imageAssetPath: "brokoli"),
        Item(id: UUID(), name: "Corn", price: 6, aisle: "Sayur", imageAssetPath: "jagung"),

        // Olahan
        Item(id: UUID(), name: "Milk", price: 12, aisle: "Olahan", imageAssetPath: "susu"),

        // Protein Harian
        Item(id: UUID(), name: "Chicken", price: 15, aisle: "Protein Harian", imageAssetPath: "ayam"),
        Item(id: UUID(), name: "Fish", price: 18, aisle: "Protein Harian", imageAssetPath: "ikan"),
        Item(id: UUID(), name: "Egg", price: 5, aisle: "Protein Harian", imageAssetPath: "telur"),

        // Protein Premium
        Item(id: UUID(), name: "Beef", price: 25, aisle: "Protein Premium", imageAssetPath: "beef"),
        
        // Barang di Cashier
        Item(id: UUID(), name: "Sausage", price: 12, aisle: "Kasir", imageAssetPath: ""),
        Item(id: UUID(), name: "Chocolate", price: 15, aisle: "Kasir", imageAssetPath: "")

    ]
}
