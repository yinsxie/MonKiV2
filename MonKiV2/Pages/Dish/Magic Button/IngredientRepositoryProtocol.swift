//
//  IngredientRepositoryProtocol.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 17/11/25.
//

// MARK: delete later, for magic button purpose, biar ada opsi gausa masukin manual UNTUK TESTING
import Foundation

protocol IngredientRepositoryProtocol {
    func getAvailableItems() -> [Item]
}

struct DummyIngredientRepository: IngredientRepositoryProtocol {

    func getAvailableItems() -> [Item] {
        return Item.items
    }
}
