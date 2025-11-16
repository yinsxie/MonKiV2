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
    
    static let mockItem = Item(id: UUID(), name: "Test item", price: 10, aisle: nil, imageAssetPath: "")
    
    // TODO: Add strings of actual asset + aisle adjustment
    static let items: [Item] = [
//        // Pokok
//        Item(id: UUID(), name: "Nasi", price: 5, aisle: "Pokok", imageAssetPath: ""),
//        Item(id: UUID(), name: "Mie", price: 5, aisle: "Pokok", imageAssetPath: ""),
//        Item(id: UUID(), name: "Roti", price: 5, aisle: "Pokok", imageAssetPath: ""),
        
        // Sayur
        Item(id: UUID(), name: "Carrot", price: 3, aisle: "Sayur", imageAssetPath: "wortel"),
        Item(id: UUID(), name: "Tomato", price: 3, aisle: "Sayur", imageAssetPath: "tomat"),
        Item(id: UUID(), name: "Broccoli", price: 4, aisle: "Sayur", imageAssetPath: "brokoli"),
        Item(id: UUID(), name: "Corn", price: 3, aisle: "Sayur", imageAssetPath: "jagung"),
//        Item(id: UUID(), name: "Kentang", price: 3, aisle: "Sayur", imageAssetPath: ""),
//        
//        // Olahan
//        Item(id: UUID(), name: "Keju", price: 8, aisle: "Olahan", imageAssetPath: ""),
//        Item(id: UUID(), name: "Susu", price: 7, aisle: "Olahan", imageAssetPath: ""),
//        Item(id: UUID(), name: "Sosis", price: 7, aisle: "Olahan", imageAssetPath: ""),
//        
//        // Protein Harian
//        Item(id: UUID(), name: "Ayam", price: 12, aisle: "Protein Harian", imageAssetPath: ""),
//        Item(id: UUID(), name: "Ikan", price: 15, aisle: "Protein Harian", imageAssetPath: ""),
        Item(id: UUID(), name: "Egg", price: 5, aisle: "Protein Harian", imageAssetPath: "telur")
//
//        // Protein Premium
//        Item(id: UUID(), name: "Daging Sapi", price: 18, aisle: "Protein Premium", imageAssetPath: ""),
//        Item(id: UUID(), name: "Udang", price: 20, aisle: "Protein Premium", imageAssetPath: "")
    ]
}
