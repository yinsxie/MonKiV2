//
//  CreateDishViewModel.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 13/11/25.
//

import Foundation
import UIKit
import CoreData

@Observable
final class CreateDishViewModel {
    weak var parent: PlayViewModel?
    private let bgProcessor = BackgroundRemoverProcessor()
    
    init(parent: PlayViewModel?) {
        self.parent = parent
    }
    
    var cgImage: CGImage?
    var isLoading = false
    var inputText: String = ""
    
    var isBagTapped = false
    var isStartCookingTapped = false
    
    var totalPurchasedPrice: Int {
        return createDishItem.reduce(0) { $0 + $1.item.price }
    }
    
    var groceriesList: [GroceryItem] {
        guard let cartItems = parent?.cashierVM.purchasedItems else { return [] }
        
        // Extract items
        let items: [Item] = cartItems.map { $0.item }
        
        // Group items by their item.id
        let grouped = Dictionary(grouping: items, by: { $0.id })
        
        print("Refreshing groceries list...")
        
        // Convert grouped items into GroceryItem, then sort by quantity
        return grouped.map { (_, items) in
            GroceryItem(
                id: UUID(),
                item: items.first ?? Item.mockItem,
                quantity: items.count
            )
        }
        .sorted { $0.item.name < $1.item.name }
    }
    
    var createDishItem: [CartItem] = []
    
    // Grouping createDishItem array into unique items with quantities for DishImageView
    var groupedDishItems: [GroceryItem] {
        let grouped = Dictionary(grouping: createDishItem, by: { $0.item.id })
        
        let groceryItems = grouped.compactMap { (_, items) -> GroceryItem? in
            guard let firstItem = items.first?.item else { return nil }
            return GroceryItem(
                id: UUID(),
                item: firstItem,
                quantity: items.count
            )
        }
        
        return groceryItems.sorted { $0.item.name < $1.item.name }
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
                let rawCgImage = try await ImagePlaygroundManager.shared.generateDish(from: inputText)
                let rawUiImage = UIImage(cgImage: rawCgImage)
                let processedUiImage = try await bgProcessor.process(rawUiImage)
                
                if let finalCgImage = processedUiImage.cgImage {
                    self.cgImage = finalCgImage
                } else { // Fallback
                    self.cgImage = rawCgImage
                }
                
                let time = CFAbsoluteTimeGetCurrent() - start
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
    
    // function untuk dev di simulator tanpa capability image playground (pengganti function generate)
    func generateMock() {
        guard !checkCheckoutItems() else { return }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
            let img = renderer.image { ctx in
                UIColor.orange.setFill()
                ctx.fill(CGRect(x: 0, y: 0, width: 512, height: 512))
                
                let symbol = UIImage(systemName: "fork.knife.circle")?.withTintColor(.white, renderingMode: .alwaysOriginal)
                symbol?.draw(in: CGRect(x: 106, y: 106, width: 300, height: 300))
            }
            
            self.cgImage = img.cgImage
            
            self.isLoading = false
            print("Mock Image Generated AND Saved successfully!")
            AudioManager.shared.play(.dishDone, pitchVariation: 0.03)
        }
    }
    
    func onSaveButtonTapped() {
        isStartCookingTapped = false
        saveDishToCollection()
        createDishItem.removeAll()
    }
    
    func saveDishToCollection() {
        guard let cgImage = self.cgImage else { return }
        let uiImage = UIImage(cgImage: cgImage)
        
        guard let savedFileName = ImageStorage.saveImage(uiImage) else {
            print("Failed to save image to disk")
            return
        }
        
        let context = CoreDataManager.shared.viewContext
        
        let newDish = Dish(context: context)
        newDish.id = UUID()
        newDish.timestamp = Date()
        newDish.totalPrice = Int32(self.totalPurchasedPrice)
        newDish.imageFileName = savedFileName
        
        let groupedItems = Dictionary(grouping: createDishItem, by: { $0.item.id })
        
        for (_, items) in groupedItems {
            if let firstItem = items.first?.item {
                let ingredient = Ingredient(context: context)
                ingredient.id = UUID()
                ingredient.name = firstItem.name
                ingredient.quantity = Int16(items.count)
                
                ingredient.dish = newDish
            }
        }
        
        CoreDataManager.shared.save()
        print("Dish saved successfully!")
    }
}
