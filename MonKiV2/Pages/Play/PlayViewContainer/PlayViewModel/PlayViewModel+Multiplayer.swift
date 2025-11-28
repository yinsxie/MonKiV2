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
        budgetSharingVM?.handleEvent(event)
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
    }
    
    func didRemotePlayerRemoveFromDish(itemName: String) {
        if let index = dishVM.createDishItem.firstIndex(where: { $0.item.name == itemName }) {
            let cartItem = dishVM.createDishItem[index]
            cashierVM.purchasedItems.append(cartItem)
            dishVM.createDishItem.remove(at: index)
            print("📡 Opponent removed \(itemName) from dish")
        }
    }
    
    func findItemByName(_ name: String) -> Item? {
        return Item.items.first(where: { $0.name == name })
    }
    
    func didLocalUserStartDragReceiptItem(itemName: String) {
        dishVM.handleOnItemDraggedFromReceipt(itemName: itemName)
    }
}
