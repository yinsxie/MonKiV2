//
//  CreateDishViewModel.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 13/11/25.
//

import Foundation
import UIKit
import Combine

@Observable
final class CreateDishViewModel: ObservableObject {
    weak var parent: PlayViewModel?
    
    init(parent: PlayViewModel?) {
        self.parent = parent
    }
    
    var cgImage: CGImage?
    var isLoading = false
    var inputText: String = ""
    
    // MARK: - DONT DELETE, ini buat nerima data object, will be used
    // kepikiran nanti pas udah co, yg dilempar itu bentuknya object si bahannya
    func setIngredients(from cartItems: [CartItem]) {
        // 1. Group by item to get quantities
        let grouped = Dictionary(grouping: cartItems, by: { $0.item.id })
        
        // 2. Create the formatted string: "QTY Item, QTY Item"
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
