//
//  IngredientService.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 17/11/25.
//

// MARK: delete later, for magic button purpose, biar ada opsi gausa masukin manual UNTUK TESTING
import Foundation

struct IngredientService {
    // MARK: kalau udah ke implement dari page cashier, ini didelet aja
    private let repository: IngredientRepositoryProtocol

    init(repository: IngredientRepositoryProtocol = DummyIngredientRepository()) {
        self.repository = repository
    }

    func getRandomIngredients(count: Int) -> [CheckoutItem] {
        let allItems = repository.getAvailableItems()

        let validCount = min(count, allItems.count)
        guard validCount > 0 else { return [] }

        let shuffledItems = allItems.shuffled().prefix(validCount)

        return shuffledItems.map { item in
            let randomQuantity = Int.random(in: 1...5)

            return ItemHeader(
                item: item,
                quantity: randomQuantity,
                originalOwner: Player.mockPlayer
            )
        }
    }

    func parseIngredients(from input: String) -> [String] {
        return input
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
    }

}
