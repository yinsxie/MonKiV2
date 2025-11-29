//
//  CreateDishViewModel.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 13/11/25.
//

import Foundation
import UIKit
import CoreData

@MainActor @Observable
final class CreateDishViewModel {
    weak var parent: PlayViewModel?
    private let bgProcessor = BackgroundRemoverProcessor()
    
    var tourButtonImage: String = "button_tour_default"
    private var tourTimer: Timer?
    
    init(parent: PlayViewModel?) {
        self.parent = parent
    }
    
    var cgImage: CGImage?
    var isLoading = false
    var inputText: String = ""
    
    
    var isBagTapped = false
    var isStartCookingTapped = false
    var isRemotePlayerStartCookingTapped: Bool = false
    var isShowMultiplayerDish: Bool = false
    
    var isCreatingMultiplayerDish: Bool {
        return parent?.gameMode == .multiplayer && isStartCookingTapped && isRemotePlayerStartCookingTapped
    }
    
    enum WhoTappedLast {
        case me
        case remotePlayer
    }
    
    var whoTappedLast: WhoTappedLast?
    
    var amountOfPlayerReady: Int {
        var count = 0
        if isStartCookingTapped {
            count += 1
        }
        if isRemotePlayerStartCookingTapped {
            count += 1
        }
        return count
    }

    var totalPurchasedPrice: Int {
        return createDishItem.reduce(0) { $0 + $1.item.price }
    }
    
    var groceriesList: [GroceryItem] {
        guard let cartItems = parent?.cashierVM.purchasedItems else { return [] }
        
        // Extract items
        let items: [Item] = cartItems.map { $0.item }
        
        // Group items by their item.id
        let grouped = Dictionary(grouping: items, by: { $0.id })
        
        // Convert grouped items into GroceryItem, then sort by quantity
        return grouped.map { (_, items) in
            GroceryItem(
                id: items.first?.id ?? UUID(),
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
    
    var CTACookButtonTitle: String {
        if parent?.gameMode == .singleplayer {
            return "Masak Sekarang"
        }
        
        return "Siap Masak"
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
    
    func generateInitialMultiplayerDish() {
        setIngredients(from: createDishItem)
        print("Started generating multiplayer dish...")
        guard !checkCheckoutItems() else {
            return
        }
        
        cgImage = nil
        
        if whoTappedLast == .me {
            print("Im the last one to tap!")
            generate()
        } else {
            print("Remote player is the last one to tap, waiting for their dish...")
            Task {
                isLoading = true
                isShowMultiplayerDish = false
                AudioManager.shared.play(.loadCooking, volume: 5.0)
            }
        }
    }
    
    func handleReceivedDishImageData(_ image: Data) {
        print("Received dish image data from remote player....")

        Task { @MainActor in
            guard let uiImage = UIImage(data: image) else { return }
            
            let processedUiImage = try await bgProcessor.process(uiImage)

            guard let finalCgImage =
                    processedUiImage.cgImage ??
                    uiImage.cgImage else {
                print("❌ Could not extract CGImage")
                return
            }

            self.cgImage = finalCgImage
            
            // Kirim isShowMultiplayerDish = true ke player lain, after that baru set isShowMultiplayerDish = true di local
            parent?.matchManager?.sendShowMultiplayerDish()
            self.isShowMultiplayerDish = true
            
            isLoading = false
        }
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
                AudioManager.shared.play(.loadCooking, volume: 5.0)
                
                // 1. Generate Raw Image
                let rawCgImage = try await ImagePlaygroundManager.shared.generateDish(from: inputText)
                let rawUiImage = UIImage(cgImage: rawCgImage)
                
                // 2. Process Image
                let processedUiImage = try await bgProcessor.process(rawUiImage)
                
                // 3. Determine Final CGImage
                var finalCgImage: CGImage! // Use a variable to hold the chosen image
                
                if let cgImage = processedUiImage.cgImage {
                    finalCgImage = cgImage
                } else { // Fallback
                    finalCgImage = rawCgImage
                }
                
                // 4. Set State (Crucial: Update self.cgImage before sending)
                self.cgImage = finalCgImage
                
                let time = CFAbsoluteTimeGetCurrent() - start
                print("Generated in \(String(format: "%.2f", time))s")
                
                // 5. Send Final Image to Remote Player
                if parent?.gameMode == .multiplayer {
                    self.isShowMultiplayerDish = false
                    // Send the determined final CGImage
                    print("Sending dish image data to remote player..., size: \(finalCgImage.width)x\(finalCgImage.height)")
                    parent?.matchManager?.sendDishImageData(cgImage: finalCgImage)
                    return
                }
                
                // 6. Final UI/Audio Updates
                AudioManager.shared.stop(.loadCooking)
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
        
        UserDefaultsManager.shared.setIsNewDishSaved(true)

        print("Dish saved successfully!")
    }
    
    func startAutoLoopAnimation() {
        stopAutoLoopAnimation()
        
        tourTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.tourButtonImage == "button_tour_default" {
                self.tourButtonImage = "button_tour_delay"
            } else {
                self.tourButtonImage = "button_tour_default"
            }
        }
    }
    
    func stopAutoLoopAnimation() {
        tourTimer?.invalidate()
        tourTimer = nil
    }
    
    func handleOnItemDraggedFromReceipt(itemName: String) {
        if parent?.gameMode != .multiplayer {
            return
        }
        parent?.matchManager?.sendReceiptItemDragged(itemName: itemName)
    }
    
    func handleRemotePlayerDraggedReceiptItem(itemName: String) {
        if parent?.gameMode != .multiplayer {
            return
        }
        
        Task { @MainActor in
            if let index = parent?.cashierVM.purchasedItems.firstIndex(where: { $0.item.name == itemName }) {
                parent?.cashierVM.purchasedItems.remove(at: index)
            }
        }
    }
    
    func handleRemotePlayerCancelledDragReceiptItem(itemName: String) {
        // add back the item to the cart
        if parent?.gameMode != .multiplayer {
            return
        }
        
        Task { @MainActor in
            if let item = parent?.findItemByName(itemName) {
                parent?.cashierVM.purchasedItems.append(CartItem(item: item))
            }
        }
    }
    
    func handleOnItemDraggedFromCreateDish(itemName: String) {
        if parent?.gameMode != .multiplayer {
            return
        }
        parent?.matchManager?.sendCreateDishItemDragged(itemName: itemName)
    }
    
    func handleRemotePlayerDraggedCreateDishItem(itemName: String) {
        if parent?.gameMode != .multiplayer {
            return
        }
        
        //remove the item from createDishItem
        Task { @MainActor in
            if let index = createDishItem.firstIndex(where: { $0.item.name == itemName }) {
                createDishItem.remove(at: index)
            }
        }
    }
    
    func handleRemotePlayerCancelledDragCreateDishItem(itemName: String) {
        if parent?.gameMode != .multiplayer {
            return
        }
        Task { @MainActor in
            if let item = parent?.findItemByName(itemName) {
                createDishItem.append(CartItem(item: item))
            }
        }
    }
    
    func sendStartCookingTappedToRemotePlayer() {
        if parent?.gameMode != .multiplayer {
            return
        }
        
        parent?.matchManager?.sendReadyCookingTapped()
    }
    
    func onBackButtonTapped() {
        if parent?.gameMode != .multiplayer {
            return
        }
        
        isStartCookingTapped = false
        
        parent?.matchManager?.sendUnreadyCookingTapped()
    }
    
    func onMultiplayerSaveButtonTapped() {
        
    }
}
