//
//  PlayViewModel+Multiplayer.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 26/11/25.
//
import SwiftUI
import GameKit

extension PlayViewModel: MatchManagerDelegate {
    
    func connectToMatch() {
        print("🔗 PlayViewModel connecting to MatchManager delegate")
        self.matchManager?.delegate = self
    }
    
    func disconnectFromMatch() {
        print("🔌 Disconnecting from match...")
        matchManager?.resetMatch()
        matchManager = nil
    }
    
    func didReceiveBudgetEvent(_ event: BudgetEvent) {
        moneyBreakVM?.handleEvent(event)
    }
        
    func didRemotePlayerPurchase(itemName: String) {
        print("📡 Opponent bought: \(itemName)")
        if let item = findItemByName(itemName) {
            cashierVM.purchasedItems.append(CartItem(item: item))
        }
    }
    
    func didRemotePlayerAddToDish(itemName: String) {
        // 1. Try to find it in purchased items to move it
        if let index = cashierVM.purchasedItems.firstIndex(where: { $0.item.name == itemName }) {
            let cartItem = cashierVM.purchasedItems[index]
            dishVM.createDishItem.append(cartItem)
            cashierVM.purchasedItems.remove(at: index)
            print("📡 Opponent added \(itemName) to dish (Moved from Bag)")
        }
        // 2. Fail-safe: If not in bag (desync), create fresh
        else if let item = findItemByName(itemName) {
            dishVM.createDishItem.append(CartItem(item: item))
            print("📡 Opponent added \(itemName) to dish (Created fresh)")
        }
        
        print("Current : dishVM.createDishItem: \(dishVM.createDishItem.map { $0.item.name })")
        dragManager.isRemotePlayerDragging = false
    }
    
    func didRemotePlayerRemoveFromDish(itemName: String) {
        if let item = findItemByName(itemName) {
            cashierVM.purchasedItems.append(CartItem(item: item))
        }
        dragManager.isRemotePlayerDragging = false
    }
    
    func findItemByName(_ name: String) -> Item? {
        return Item.items.first(where: { $0.name == name })
    }
    
    func didLocalUserStartDragReceiptItem(itemName: String) {
        dishVM.handleOnItemDraggedFromReceipt(itemName: itemName)
    }
    
    func didLocalUserStartedDragCreateDishItem(itemName: String) {
        dishVM.handleOnItemDraggedFromCreateDish(itemName: itemName)
    }
    
    func didRemotePlayerDragReceiptItem(itemName: String) {
        dragManager.isRemotePlayerDragging = true
        dishVM.handleRemotePlayerDraggedReceiptItem(itemName: itemName)
    }
    
    func didRemotePlayerCancelReceiptItem(itemName: String) {
        dragManager.isRemotePlayerDragging = false
        dishVM.handleRemotePlayerCancelledDragReceiptItem(itemName: itemName)
    }
    
    func didRemotePlayerDragCreateDishItem(itemName: String) {
        dragManager.isRemotePlayerDragging = true
        dishVM.handleRemotePlayerDraggedCreateDishItem(itemName: itemName)
    }
    
    func didRemotePlayerCancelCreateDishItem(itemName: String) {
        dragManager.isRemotePlayerDragging = false
        dishVM.handleRemotePlayerCancelledDragCreateDishItem(itemName: itemName)
    }
    
    func didRemotePlayerReadyInCreateDish() {
        dishVM.isRemotePlayerStartCookingTapped = true
        show(.remotePlayerReadyToCook)
        dishVM.whoTappedLast = .remotePlayer
    }
    
    func didRemotePlayerUnreadyInCreateDish() {
        dishVM.isRemotePlayerStartCookingTapped = false
        hideNotification()
    }
    
    func didReceiveDishImageData(_ image: Data) {
        dishVM.handleReceivedDishImageData(image)
    }
    
    func didReceiveShowMultiplayerDish() {
        dishVM.isShowMultiplayerDish = true
        dishVM.isLoading = false
    }
    
    func didReceiveHideMultiplayerDish() {
        dishVM.isShowMultiplayerDish = false
        dishVM.isLoading = true
        AudioManager.shared.play(.loadCooking, volume: 5)
    }
    
    func didReceiveToggleReadyToSaveDishImage() {
        dishVM.isRemoteReadySaveImage.toggle()
    }
}
