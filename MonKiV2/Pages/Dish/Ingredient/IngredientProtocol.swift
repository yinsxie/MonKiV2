//
//  IngredientProtocol.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 13/11/25.
//

// MARK: delete later, for magic button purpose, biar ada opsi gausa masukin manual UNTUK TESTING
import Foundation

protocol IngredientRepositoryProtocol {
    func getAvailableIngredientNames() -> [String]
}

struct DummyIngredientRepository: IngredientRepositoryProtocol {
    
    private let dummyNames: [String] = [
        "Egg", "Tomato", "Milk", "Cheese", "Chicken",
        "Beef", "Brocolli", "Rice", "Pasta", "Corn",
        "Bread", "Shrimp", "Fish", "Sausage", "Potato", "Carrot"
    ]
    
    func getAvailableIngredientNames() -> [String] {
        return dummyNames
    }
}
