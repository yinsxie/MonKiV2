//
//  PlayViewModel+DropHandler.swift
//  MonKiV2
//
//  Created by William on 24/11/25.
//

import SwiftUI

// MARK: Drop Handlers
extension PlayViewModel {
    
    func handleDropFailed(draggedItem: DraggedItem) {
        print("Drop failed (Invalid Zone). Clearing item without animation.")
        
        DispatchQueue.main.async {
            self.dragManager.currentDraggedItem = nil
        }
    }
    
    func handleGroceryDrop(zone: DropZoneType, groceryItem: Item, draggedItem: DraggedItem) {
        switch zone {
        case .cart:
            handleGroceryDropOnCart(groceryItem: groceryItem, draggedItem: draggedItem)
        case .cashierLoadingCounter:
            handleCashierOnLoadingCounter(groceryItem: groceryItem, draggedItem: draggedItem)
        case .cashierRemoveItem:
            handleGroceryDropOnRemoveZone(draggedItem: draggedItem, groceryItem: groceryItem)
        case .shelfReturnItem:
            handleGroceryDropOnShelf(draggedItem: draggedItem)
        case .createDish:
            handleGroceryDropOnCreateDish(groceryItem: groceryItem, draggedItem: draggedItem)
        case .createDishOverlay:
            handleGroceryDropOnCreateDishOverlay(groceryItem: groceryItem, draggedItem: draggedItem)
        default:
            DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
        }
    }
    
    func handleMoneyDrop(zone: DropZoneType, currency: Currency, draggedItem: DraggedItem) {
        //        withAnimation(.spring) {
        switch zone {
        case .cashierPaymentCounter:
            if cashierVM.isPlayerStopScrollingWhileReceivedMoney {
                print("Player is currently not allowed to drop money on payment counter.")
                return
            }
            print("Dropped money on payment counter")
            
            // Put money
            cashierVM.isPlayerStopScrollingWhileReceivedMoney = true
            dropMoneyToCounter(withCurrency: currency)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.handleOnPaymentCounter()
            }
        case .wallet:
            handleMoneyDropOnWallet(currency: currency, draggedItem: draggedItem)
        default:
            print("Dropped money on an invalid zone (\(zone.rawValue))")
        }
        //        }
    }
    
    func dropMoneyToCounter(withCurrency currency: Currency) {
        print("Dropped money (\(currency.value)) on payment counter")
        
        if cashierVM.checkOutItems.isEmpty {
            return
        }
        DispatchQueue.main.async {
            self.cashierVM.acceptMoney(Money(forCurrency: currency))
            self.walletVM.removeFirstMoney(withCurrency: currency)
        }
    }
    
    func dropMoneyBackToWallet() {
        DispatchQueue.main.async {
            self.walletVM.moneys.append(contentsOf: self.cashierVM.receivedMoney)
            self.cashierVM.receivedMoney.removeAll()
        }
    }
    
    func handleGroceryDropOnCart(groceryItem: Item, draggedItem: DraggedItem) {
        
        if let source = draggedItem.source {
            switch source {
            case .cashierCounter:
                // from counter
                if self.cartVM.isFull {
                    self.cartVM.triggerShake()
                    print("Cart full, item not moved.")
                    AudioManager.shared.play(.dropFail)
                    
                    let fall = FloatingItemFeedback(
                        id: UUID(),
                        item: groceryItem,
                        startPoint: self.dragManager.currentDragLocation,
                        originPoint: self.dragManager.dragStartLocation,
                        shouldFadeOut: false, // NO FADE
                        trackedItemID: draggedItem.id
                    )
                    self.floatingItems.append(fall)
                    self.itemsCurrentlyAnimating.append(draggedItem.id) // Hide original item
                    self.dragManager.currentDraggedItem = nil
                    return
                }
                
                if let cartItem = self.cashierVM.popFromCounter(withId: draggedItem.id) {
                    DispatchQueue.main.async {
                        self.cartVM.addExistingItem(cartItem)
                        AudioManager.shared.play(.dropItemCart, pitchVariation: 0.03)
                        self.dragManager.currentDraggedItem = nil
                    }
                }
            case .cart:
                DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
            default:
                break
            }
        } else {
            // from shelf
            if self.cartVM.isFull {
                self.cartVM.triggerShake()
                print("Cart full, item not added.")
                AudioManager.shared.play(.dropFail)
                
                let fall = FloatingItemFeedback(
                    id: UUID(),
                    item: groceryItem,
                    startPoint: self.dragManager.currentDragLocation,
                    originPoint: self.dragManager.dragStartLocation,
                    shouldFadeOut: true, // FADE OUT
                    trackedItemID: draggedItem.id
                )
                self.floatingItems.append(fall)
                self.dragManager.currentDraggedItem = nil
                return
            }
            
            DispatchQueue.main.async {
                self.cartVM.addNewItem(groceryItem)
                AudioManager.shared.play(.dropItemCart, pitchVariation: 0.03)
                self.dragManager.currentDraggedItem = nil
            }
        }
    }
    
    func handleGroceryDropOnRemoveZone(draggedItem: DraggedItem, groceryItem: Item) {
        print("Remove from cart")
        AudioManager.shared.play(.dropItemTrash, pitchVariation: 0.03)
        
        DispatchQueue.main.async {
            self.cashierVM.discardedAmountTracker -= groceryItem.price
        }
        
        if let source = draggedItem.source {
            switch source {
            case .cart:
                DispatchQueue.main.async {
                    self.cartVM.removeItem(withId: draggedItem.id)
                    self.dragManager.currentDraggedItem = nil
                }
            case .cashierCounter:
                DispatchQueue.main.async {
                    self.cashierVM.removeFromCounter(withId: draggedItem.id)
                    self.dragManager.currentDraggedItem = nil
                }
            default:
                break
            }
        }
    }
    
    func handleGroceryDropOnShelf(draggedItem: DraggedItem) {
        if draggedItem.source == .cart {
            AudioManager.shared.play(.dropItemTrash, pitchVariation: 0.03)
            DispatchQueue.main.async {
                self.cartVM.removeItem(withId: draggedItem.id)
                self.dragManager.currentDraggedItem = nil
            }
        } else {
            DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
        }
    }
    
    func handleGroceryDropOnCreateDish(groceryItem: Item, draggedItem: DraggedItem) {
        if draggedItem.source == .createDishOverlay {
            DispatchQueue.main.async {
                // Local Update
                self.dishVM.createDishItem.append(CartItem(item: groceryItem))
                guard let index = self.cashierVM.purchasedItems.firstIndex(where: { $0.item.id == draggedItem.id }) else { return }
                self.cashierVM.purchasedItems.remove(at: index)
                self.dragManager.currentDraggedItem = nil
                
                // Network Update
                self.matchManager?.sendAddToDish(itemName: groceryItem.name)
            }
        }
    }
    
    func handleGroceryDropOnCreateDishOverlay(groceryItem: Item, draggedItem: DraggedItem) {
        if draggedItem.source == .createDish {
            DispatchQueue.main.async {
                // Local Update
                self.cashierVM.purchasedItems.append(CartItem(item: groceryItem))
                guard let index = self.dishVM.createDishItem.firstIndex(where: { $0.id == draggedItem.id }) else { return }
                self.dishVM.createDishItem.remove(at: index)
                self.dragManager.currentDraggedItem = nil
                
                // Network Update
                self.matchManager?.sendRemoveFromDish(itemName: groceryItem.name)
            }
        }
    }
    
    func handleOnPaymentCounter() {
        //        print("Dropped money (\(price)) on payment counter")
        //        self.walletVM.removeItem(withId: draggedItem.id)
        //        let droppedMoney = Money(price: price)
        //        self.cashierVM.acceptMoney(droppedMoney)
        let requiredAmount = self.cashierVM.totalPrice
        
        // Guard checks
        guard requiredAmount > 0 else {
            DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
            cashierVM.isPlayerStopScrollingWhileReceivedMoney = false
            return
        }
        
        // KONDISI 2: Duitnya yang di kasih ga cukup
        guard self.cashierVM.totalReceivedMoney >= requiredAmount else {
            cashierVM.isPlayerStopScrollingWhileReceivedMoney = false
            return
        }
        
        // Success logic
        AudioManager.shared.play(.paymentSuccess, pitchVariation: 0.02)
        
        // Itung kembalian kalau ada
        // MARK: Case unit nya 1 (old version)
        //        let changeAmount = self.cashierVM.totalReceivedMoney - requiredAmount
        //
        //        if changeAmount != 0 {
        //            self.walletVM.addMoney(Currency.breakdown(from: changeAmount))
        //        }
        
        // Case unit udh pecahan
        // MARK: Case unit nya pecahan (new version)
        var remaining = requiredAmount
        var usedMoney: [Money] = []
        var unusedMoney: [Money] = []
        var leftoverFromLastUsedBill = 0
        
        // Sort received money from smallest to largest (we try to use smaller bills first)
        let sortedReceived = self.cashierVM.receivedMoney.sorted { $0.currency.value < $1.currency.value }
        
        for money in sortedReceived {
            if remaining > 0 {
                let prevRemaining = remaining
                remaining -= money.currency.value
                usedMoney.append(money)
                
                // If this bill made us cover (or overpay), compute leftover from this bill only
                if remaining <= 0 {
                    // prevRemaining was > 0 (we entered because remaining > 0)
                    // leftover = portion of this bill that is not needed:
                    leftoverFromLastUsedBill = money.currency.value - prevRemaining
                    // don't break here — we'll treat the rest of loop as unused once remaining <= 0
                }
            } else {
                // money not used at all — return intact
                unusedMoney.append(money)
            }
        }
        
        if unusedMoney.isEmpty && leftoverFromLastUsedBill == 0 {
            // This means we had exact payment with unused bills
            print("exact")
            DispatchQueue.main.async {
                self.cashierVM.isPlayerStopScrollingWhileReceivedMoney = false
                self.cashierVM.receivedMoney.removeAll()
                self.cashierVM.checkOutSuccess()
            }
            return
        }
        
        // Return unused (not used) bills intact
        withAnimation {
            cashierVM.isAnimatingReturnMoney = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            if !unusedMoney.isEmpty {
                DispatchQueue.main.async {
                    // New Version : append to returned Money first
                    self.cashierVM.returnedMoney.append(contentsOf: unusedMoney)
                }
            }
            
            // If there is leftover from the last used bill, break it down and add to wallet
            if leftoverFromLastUsedBill > 0 {
                let changeCurrencies = Currency.breakdown(from: leftoverFromLastUsedBill)
                if !changeCurrencies.isEmpty {
                    DispatchQueue.main.async {
                        // New Version : add to returned Money first
                        self.cashierVM.addReturnedMoney(changeCurrencies)
                    }
                }
            }
            
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.cashierVM.isStartingReturnMoneyAnimation = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.cashierVM.receivedMoney.removeAll()
                // New Version: Dont trigger checkOutSuccess from here, trigger it when user collects returned money
                //            self.cashierVM.checkOutSuccess()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    self.cashierVM.isAnimatingReturnMoney = false
                    self.cashierVM.isReturnedMoneyPrompted = true
                    self.cashierVM.isPlayerStopScrollingWhileReceivedMoney = false
                }
            }
        }
    }
    
    func handleMoneyDropOnWallet(currency: Currency, draggedItem: DraggedItem) {
        print("Dropped money (\(currency.value)) back on wallet")
        if draggedItem.source != .wallet {
            DispatchQueue.main.async {
                self.walletVM.addMoney(currency)
                self.cashierVM.receivedMoney.removeAll(where: { $0.id == draggedItem.id })
                self.dragManager.currentDraggedItem = nil
            }
        }
    }
    
    func handleCashierOnLoadingCounter(groceryItem: Item, draggedItem: DraggedItem) {
        guard let source = draggedItem.source, source == .cart else {
            DispatchQueue.main.async { self.dragManager.currentDraggedItem = nil }
            return
        }
        
        // If counter is not full
        if !self.cashierVM.isLimitCounterReached() {
            AudioManager.shared.play(.scanItem, pitchVariation: 0.02)
            if let cartItem = self.cartVM.popItem(withId: draggedItem.id) {
                DispatchQueue.main.async {
                    self.cashierVM.addToCounter(cartItem)
                    self.dragManager.currentDraggedItem = nil
                }
            }
            return
        } else {
            AudioManager.shared.play(.dropFail)
            
            let fall = FloatingItemFeedback(
                id: UUID(),
                item: groceryItem,
                startPoint: self.dragManager.currentDragLocation,
                originPoint: self.dragManager.dragStartLocation,
                shouldFadeOut: false, // NO FADE
                trackedItemID: draggedItem.id
            )
            self.floatingItems.append(fall)
            self.itemsCurrentlyAnimating.append(draggedItem.id) // Hide original item
            self.dragManager.currentDraggedItem = nil
        }
    }
}
