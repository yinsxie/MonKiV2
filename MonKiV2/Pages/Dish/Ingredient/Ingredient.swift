//
//  Ingredient.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 13/11/25.
//

// MARK: bisa jadi ini udah ada modelnya, can be delete later, for dummy data only
import Foundation

struct Ingredient: Identifiable {
    let id = UUID()
    let name: String
    let quantity: Int
}

// MARK: - Helper Extensions (ini bisa dibawa ke file si model ingredientnya)

extension Ingredient {
    /**
     * Sebuah computed property untuk memformat
     * SATU ingredient menjadi string.
     * Contoh: "5 Egg"
     */
    var formatted: String {
        return "\(quantity) \(name)"
    }
}

extension Array where Element == Ingredient {
    /**
     * Sebuah computed property untuk memformat
     * ARRAY dari ingredients menjadi satu string.
     * Contoh: "5 Egg, 2 Tomato"
     */
    func formattedAllIngredientsToString() -> String {
        return self.map { $0.formatted }.joined(separator: ", ")
    }
}
