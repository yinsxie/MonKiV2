//
//  CreateDishViewModel.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 13/11/25.
//

import Foundation
import UIKit
import Combine

@MainActor
final class CreateDishViewModel: ObservableObject {
    @Published var cgImage: CGImage?
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let ingredientService = IngredientService()
    
    @Published var inputText: String = "" {
        didSet { parseIngredients() } // MARK: kalau udah integrate, ini didsetnya apus aja
    }
    
    // MARK: - delete later, for magic button purpose, biar ada opsi gausa masukin manual UNTUK TESTING
    @Published private(set) var ingredientList: [String] = []
    func generateRandomIngredients(count: Int) {
        let randomIngredients = ingredientService.getRandomIngredients(count: count)
        let ingredientString = randomIngredients.formattedAllIngredientsToString()
        self.inputText = ingredientString
    }
    private func parseIngredients() {
        ingredientList = ingredientService.parseIngredients(from: inputText)
    }
    
    // MARK: - DONT DELETE, ini buat nerima data object, will be used
    // kepikiran nanti pas udah co, yg dilempar itu bentuknya object si bahannya
    func setIngredients(from objects: [Ingredient]) {
        let ingredientString = objects.formattedAllIngredientsToString()
        self.inputText = ingredientString
    }
    
    func generate() {
        // MARK: ganti ingredientlist dengan object ingredient yg di co, buat guard, idk butuh apa ngga
        guard !ingredientList.isEmpty else {
            errorMessage = "Add at least one ingredient"
            return
        }
        
        Task {
            isLoading = true
            errorMessage = nil
            let start = CFAbsoluteTimeGetCurrent()
            
            do {
                print(inputText)
                let image = try await ImagePlaygroundManager.shared.generateDish(from: inputText)
                let time = CFAbsoluteTimeGetCurrent() - start
                cgImage = image
                print("Generated in \(String(format: "%.2f", time))s")
            } catch {
                errorMessage = error.localizedDescription
                print("Generate failed: \(error)")
            }
            isLoading = false
        }
    }
    
}
