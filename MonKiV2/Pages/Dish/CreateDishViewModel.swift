//
//  CreateDishViewModel.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 13/11/25.
//

import Foundation
import UIKit

@Observable
final class CreateDishViewModel {
    weak var parent: PlayViewModel?
    
    init(parent: PlayViewModel?) {
        self.parent = parent
    }
    
    var cgImage: CGImage?
    var isLoading = false
    var inputText: String = ""
    
    var totalPurchasedPrice: Int {
        guard let parent = parent else { return 0 }
        return parent.cashierVM.purchasedItems.reduce(0) { $0 + $1.item.price }
    }
    
    func setIngredients(from cartItems: [CartItem]) {
        let grouped = Dictionary(grouping: cartItems, by: { $0.item.id })
        
        let ingredientStrings = grouped.compactMap { (_, items) -> String? in
            guard let item = items.first?.item else { return nil }
            return "\(items.count) \(item.name)"
        }
        
        let ingredientString = ingredientStrings.joined(separator: ", ")
        self.inputText = ingredientString
        print("\(inputText)")
    }
    
    func generate() {
        guard !checkCheckoutItems() else {
            return
        }
        
        Task {
            isLoading = true
            let start = CFAbsoluteTimeGetCurrent()
            
            do {
                print(inputText)
                let image = try await ImagePlaygroundManager.shared.generateDish(from: inputText)
                let time = CFAbsoluteTimeGetCurrent() - start
                cgImage = image
                print("Generated in \(String(format: "%.2f", time))s")
                
                AudioManager.shared.play(.dishDone, pitchVariation: 0.03)
                
            } catch {
                print("Generate failed: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    func checkCheckoutItems() -> Bool {
        let trimmedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedInput.isEmpty
    }
    
}
